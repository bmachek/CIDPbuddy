package de.gbs_cidp.cidpbuddy

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import id.flutter.flutter_background_service.BackgroundService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            BackgroundService.enqueue(context)
        }
    }
}
