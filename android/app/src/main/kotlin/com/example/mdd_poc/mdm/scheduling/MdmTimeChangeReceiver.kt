package com.example.mdd_poc.mdm.scheduling

import android.app.AlarmManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Schedules are wall-clock based, so a clock or time-zone change can move
 * the device into or out of an allowed window and invalidates the armed
 * alarm. Re-evaluate everything when that happens, and also when the exact
 * alarm access is granted or revoked.
 */
class MdmTimeChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_TIME_CHANGED -> synchronizeSchedules(context, "time-change")
            Intent.ACTION_TIMEZONE_CHANGED -> synchronizeSchedules(context, "timezone-change")
            AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED ->
                synchronizeSchedules(context, "exact-alarm-access-change")
        }
    }
}
