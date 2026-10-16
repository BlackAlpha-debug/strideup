package com.strideup.stride_up

import android.Manifest
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime
import kotlin.math.max

/** One sensor owner shared by the visible activity and foreground service. */
class StepTracker private constructor(private val context: Context) : SensorEventListener {
    companion object {
        private var instance: StepTracker? = null
        fun get(context: Context): StepTracker = instance ?: StepTracker(context.applicationContext).also { instance = it }
    }
    private val prefs = context.getSharedPreferences("stride_steps", Context.MODE_PRIVATE)
    private val sensors = context.getSystemService(SensorManager::class.java)
    private val handler = Handler(Looper.getMainLooper())
    private val motionDetector = MotionStepDetector()
    private val hardwareTimes = ArrayDeque<Long>()
    var onChange: (() -> Unit)? = null
    var onNotification: (() -> Unit)? = null
    var visible = false
        set(value) { field = value; reconcile() }
    var serviceActive = false
        set(value) { field = value; reconcile() }
    private var listening = false
    private var error: String? = null
    private var registered = mutableListOf<Sensor>()
    private var pendingFast = prefs.getInt("pendingFast", 0)
    val enabled get() = prefs.getBoolean("enabled", false)
    val notifications get() = prefs.getBoolean("notifications", false)
    val accent get() = prefs.getInt("accent", 0xFF00F2FF.toInt())
    val weightKg get() = prefs.getFloat("weightKg", 70f).toDouble()
    val stepLengthCm get() = prefs.getFloat("stepLengthCm", 76.2f).toDouble()
    private val mode get() = prefs.getString("mode", "responsive") ?: "responsive"
    private val sensitivity get() = prefs.getFloat("sensitivity", .6f).toDouble()
    val backgroundAllowed get() = enabled && notifications && notificationPermission() && stepPermission()
    private val midnight = object : Runnable {
        override fun run() { publish(); scheduleMidnight() }
    }

    fun stepPermission() = context.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_GRANTED
    fun notificationPermission(): Boolean =
        (Build.VERSION.SDK_INT < 33 || context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) &&
            context.getSystemService(NotificationManager::class.java).areNotificationsEnabled() &&
            (context.getSystemService(NotificationManager::class.java).getNotificationChannel(StepTrackingService.CHANNEL)?.importance != NotificationManager.IMPORTANCE_NONE)

    fun configure(args: Map<*, *>) {
        val oldMode = mode
        val oldSensitivity = sensitivity
        val edit = prefs.edit()
        if (!prefs.getBoolean("migrated", false)) {
            (args["history"] as? Map<*, *>)?.forEach { (day, steps) ->
                edit.putInt("steps_$day", (steps as Number).toInt())
            }
            edit.putInt("total", (args["total"] as? Number)?.toInt() ?: 0)
            edit.putBoolean("migrated", true)
        }
        edit.putBoolean("enabled", args["enabled"] == true)
            .putBoolean("notifications", args["notifications"] == true)
            .putInt("accent", (args["accent"] as? Number)?.toInt() ?: accent)
            .putFloat("weightKg", (args["weightKg"] as? Number)?.toFloat() ?: 70f)
            .putFloat("stepLengthCm", (args["stepLengthCm"] as? Number)?.toFloat() ?: 76.2f)
            .putString("mode", args["mode"] as? String ?: "responsive")
            .putFloat("sensitivity", (args["sensitivity"] as? Number)?.toFloat() ?: .6f)
            .apply()
        if (oldMode != mode || oldSensitivity != sensitivity) stopSensors(clearBaseline = false)
        reconcile()
        publish()
    }

    private fun register(sensor: Sensor?, period: Int, latencyUs: Int = 0): Boolean {
        if (sensor == null) return false
        val ok = sensors.registerListener(this, sensor, period, latencyUs)
        if (ok) registered.add(sensor)
        return ok
    }

    private fun reconcile() {
        val shouldListen = enabled && stepPermission() && (visible || serviceActive)
        if (shouldListen && !listening) {
            registered.clear()
            val counter = sensors.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
            val detector = sensors.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
            val counterLatency = if (mode == "battery") 5_000_000 else 0
            val counterOk = register(counter, SensorManager.SENSOR_DELAY_NORMAL, counterLatency)
            val detectorOk = mode != "battery" && register(detector, SensorManager.SENSOR_DELAY_FASTEST)
            val motionOk = mode == "sensitive" && register(
                sensors.getDefaultSensor(Sensor.TYPE_ACCELEROMETER), SensorManager.SENSOR_DELAY_GAME)
            listening = counterOk || detectorOk || motionOk
            error = if (listening) null else "This device has no usable step or motion sensor."
            if (listening) scheduleMidnight()
        } else if (!shouldListen && listening) {
            stopSensors(clearBaseline = true)
        }
    }

    private fun stopSensors(clearBaseline: Boolean) {
        sensors.unregisterListener(this)
        registered.clear()
        listening = false
        hardwareTimes.clear()
        if (clearBaseline) {
            pendingFast = 0
            prefs.edit().remove("raw").remove("rawDay").putInt("pendingFast", 0).apply()
        }
        handler.removeCallbacks(midnight)
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (!listening || !enabled) return
        when (event.sensor.type) {
            Sensor.TYPE_STEP_DETECTOR -> acceptFastStep(event.timestamp, hardware = true)
            Sensor.TYPE_ACCELEROMETER -> {
                val timestamps = motionDetector.sample(event.values[0], event.values[1], event.values[2],
                    event.timestamp, sensitivity)
                timestamps.forEach { timestamp ->
                    while (hardwareTimes.isNotEmpty() && timestamp - hardwareTimes.first() > 2_000_000_000L) hardwareTimes.removeFirst()
                    if (hardwareTimes.none { kotlin.math.abs(it - timestamp) < 650_000_000L }) {
                        acceptFastStep(timestamp, hardware = false)
                    }
                }
            }
            Sensor.TYPE_STEP_COUNTER -> reconcileCounter(event.values[0].toInt(), event.timestamp)
        }
    }

    private fun acceptFastStep(timestampNs: Long, hardware: Boolean) {
        if (hardware) {
            hardwareTimes.addLast(timestampNs)
            while (hardwareTimes.size > 8) hardwareTimes.removeFirst()
        }
        val last = prefs.getLong("lastFastNs", 0L)
        if (last != 0L && kotlin.math.abs(timestampNs - last) < 240_000_000L) return
        prefs.edit().putLong("lastFastNs", timestampNs).apply()
        addSteps(1, eventMillis(timestampNs))
        pendingFast++
        prefs.edit().putInt("pendingFast", pendingFast).apply()
    }

    private fun reconcileCounter(raw: Int, timestampNs: Long) {
        val boot = Settings.Global.getInt(context.contentResolver, Settings.Global.BOOT_COUNT, -1)
        val previous = prefs.getInt("raw", -1)
        val sameBoot = prefs.getInt("boot", -2) == boot
        val delta = StepCounter.delta(previous, raw, sameBoot)
        val eventMillis = eventMillis(timestampNs)
        val eventDay = dayFor(eventMillis)
        val previousDay = prefs.getString("rawDay", null)
        if (previous >= 0 && sameBoot) {
            val correction = delta - pendingFast
            if (correction > 0 && previousDay != null && previousDay != eventDay) {
                addUndated(correction)
            } else if (correction != 0) {
                addSteps(correction, eventMillis)
            }
        }
        pendingFast = 0
        prefs.edit().putInt("raw", raw).putInt("boot", boot)
            .putString("rawDay", eventDay).putInt("pendingFast", 0).apply()
        publish()
    }

    private fun eventMillis(timestampNs: Long) =
        System.currentTimeMillis() - (SystemClock.elapsedRealtimeNanos() - timestampNs) / 1_000_000

    private fun addSteps(delta: Int, millis: Long) {
        if (delta == 0) return
        val day = dayFor(millis)
        val key = "steps_$day"
        val oldDay = prefs.getInt(key, 0)
        val applied = if (delta < 0) -minOf(oldDay, -delta) else delta
        prefs.edit().putInt(key, max(0, oldDay + applied))
            .putInt("total", max(0, prefs.getInt("total", 0) + applied)).apply()
        publish()
    }

    private fun dayFor(millis: Long) =
        Instant.ofEpochMilli(millis).atZone(ZoneId.systemDefault()).toLocalDate().toString()

    private fun addUndated(delta: Int) {
        if (delta <= 0) return
        prefs.edit()
            .putInt("undated", prefs.getInt("undated", 0) + delta)
            .putInt("total", prefs.getInt("total", 0) + delta)
            .apply()
        publish()
    }

    private fun scheduleMidnight() {
        handler.removeCallbacks(midnight)
        val now = ZonedDateTime.now()
        val next = now.toLocalDate().plusDays(1).atStartOfDay(now.zone)
        handler.postDelayed(midnight, java.time.Duration.between(now, next).toMillis())
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    fun snapshot(): Map<String, Any?> {
        val day = LocalDate.now().toString()
        val history = prefs.all.filterKeys { it.startsWith("steps_") }
            .mapKeys { it.key.removePrefix("steps_") }
        val sensorMode = when {
            registered.any { it.type == Sensor.TYPE_ACCELEROMETER } -> "High sensitivity motion + hardware"
            registered.any { it.type == Sensor.TYPE_STEP_DETECTOR } -> "Responsive hardware detector"
            registered.any { it.type == Sensor.TYPE_STEP_COUNTER } -> "Battery saver counter"
            else -> ""
        }
        return mapOf("today" to (history[day] ?: 0), "total" to prefs.getInt("total", 0),
            "history" to history, "running" to listening, "error" to error,
            "notificationGranted" to notificationPermission(), "sensorMode" to sensorMode,
            "undated" to prefs.getInt("undated", 0))
    }
    fun publish() { onChange?.invoke(); onNotification?.invoke() }
}
