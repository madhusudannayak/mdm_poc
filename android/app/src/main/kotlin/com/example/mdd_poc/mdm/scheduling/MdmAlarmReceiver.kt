package com.example.mdd_poc.mdm.scheduling

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Fires at a schedule transition: enforce it and arm the next one. */
class MdmAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_SCHEDULE_TRANSITION) return
        synchronizeSchedules(context, "alarm")
    }

    companion object {
        const val ACTION_SCHEDULE_TRANSITION = "com.example.mdd_poc.mdm.action.SCHEDULE_TRANSITION"
    }
}
