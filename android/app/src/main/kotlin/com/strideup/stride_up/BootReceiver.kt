package com.strideup.stride_up

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        val tracker = StepTracker.get(context)
        if (tracker.backgroundAllowed) {
            try { context.startForegroundService(Intent(context, StepTrackingService::class.java)) }
            catch (_: Exception) { /* Reopening the app retries when an OEM blocks boot starts. */ }
        }
    }
}
