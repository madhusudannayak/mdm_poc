package com.example.mdd_poc.mdm.scheduling

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Alarms do not survive a reboot or an app update. After either, load the
 * persisted schedules, apply any transition that was missed while the
 * device was off, and arm the next alarm.
 */
class MdmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> synchronizeSchedules(context, "boot")
            Intent.ACTION_MY_PACKAGE_REPLACED -> synchronizeSchedules(context, "app-update")
        }
    }
}
