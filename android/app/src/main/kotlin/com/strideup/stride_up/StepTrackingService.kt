package com.strideup.stride_up

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import java.text.NumberFormat

class StepTrackingService : Service() {
    companion object { const val CHANNEL = "stride_steps"; private const val ID = 2001 }
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var tracker: StepTracker
    private var lastUpdate = 0L
    private var pending = false
    private val update = Runnable {
        pending = false
        if (tracker.backgroundAllowed) {
            getSystemService(NotificationManager::class.java).notify(ID, notification())
            lastUpdate = SystemClock.elapsedRealtime()
        } else stopSelf()
    }

    override fun onCreate() {
        super.onCreate()
        tracker = StepTracker.get(this)
        val channel = NotificationChannel(CHANNEL, "Live step count", NotificationManager.IMPORTANCE_LOW)
        channel.description = "Quiet steps and estimated calories while background tracking is on"
        channel.setSound(null, null)
        channel.enableVibration(false)
        channel.setShowBadge(false)
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!tracker.backgroundAllowed) { stopSelf(); return START_NOT_STICKY }
        try {
            if (Build.VERSION.SDK_INT >= 34) startForeground(ID, notification(), ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH)
            else startForeground(ID, notification())
            tracker.serviceActive = true
            tracker.onNotification = {
                if (!pending) {
                    pending = true
                    handler.postDelayed(update, (2_000 - (SystemClock.elapsedRealtime() - lastUpdate)).coerceAtLeast(0))
                }
            }
        } catch (_: SecurityException) { stopSelf(); return START_NOT_STICKY }
        return START_STICKY
    }

    private fun notification(): Notification {
        val steps = (tracker.snapshot()["today"] as Number).toInt()
        val open = PendingIntent.getActivity(this, 0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val kcal = Math.round(steps * (tracker.stepLengthCm / 100_000.0) * tracker.weightKg * 0.5)
        return Notification.Builder(this, CHANNEL)
            .setSmallIcon(R.drawable.ic_step_notification)
            .setContentTitle("${NumberFormat.getIntegerInstance().format(steps)} steps today")
            .setContentText("${NumberFormat.getIntegerInstance().format(kcal)} kcal estimated · StrideUp")
            .setSubText("StrideUp · Walking activity")
            .setColor(tracker.accent).setColorized(true)
            .setContentIntent(open).setOngoing(true).setOnlyAlertOnce(true)
            .setShowWhen(false).setCategory(Notification.CATEGORY_STATUS)
            .setVisibility(Notification.VISIBILITY_PUBLIC).build()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        tracker.onNotification = null
        tracker.serviceActive = false
        stopForeground(STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }
    override fun onBind(intent: Intent?): IBinder? = null
}
