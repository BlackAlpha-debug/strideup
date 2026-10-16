package com.strideup.stride_up

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.Intent

class MainActivity : FlutterActivity() {
    private val tracker by lazy { StepTracker.get(this) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "stride_up/steps").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "configure" -> {
                        tracker.configure(call.arguments as Map<*, *>)
                        updateService()
                        result.success(tracker.snapshot())
                    }
                    "snapshot" -> result.success(tracker.snapshot())
                    "appInfo" -> {
                        val info = packageManager.getPackageInfo(packageName, 0)
                        result.success(mapOf("version" to info.versionName,
                            "build" to if (android.os.Build.VERSION.SDK_INT >= 28) info.longVersionCode.toString() else @Suppress("DEPRECATION") info.versionCode.toString()))
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) { result.error("step_tracking", e.message, null) }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "stride_up/step_events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                tracker.onChange = { if (tracker.visible) events.success(tracker.snapshot()) }
                events.success(tracker.snapshot())
            }
            override fun onCancel(arguments: Any?) { tracker.onChange = null }
        })
    }

    private fun updateService() {
        val intent = Intent(this, StepTrackingService::class.java)
        if (tracker.backgroundAllowed) startForegroundService(intent) else stopService(intent)
    }

    override fun onResume() {
        super.onResume()
        tracker.visible = true
        updateService()
        tracker.publish()
    }

    override fun onStop() { tracker.visible = false; super.onStop() }
    override fun onDestroy() { tracker.onChange = null; super.onDestroy() }
}
