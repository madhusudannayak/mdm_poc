package com.example.mdd_poc.mdm.scheduling

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.example.mdd_poc.mdm.utils.AndroidVersionUtils
import java.util.concurrent.TimeUnit

/**
 * Arms the wake-ups that drive schedule enforcement.
 *
 * Exactly one alarm exists at any time: the next transition across all
 * schedules. It always reuses the same PendingIntent, so re-arming replaces
 * the previous alarm and duplicates cannot accumulate.
 *
 * Exact timing needs the "Alarms & reminders" special access on Android
 * 12+. Without it an inexact alarm is used, which Android may deliver late.
 * A periodic WorkManager job additionally reconciles state so a late or
 * missed alarm never leaves an application in the wrong state for long.
 */
class MdmAlarmScheduler(private val context: Context) {
    private val alarmManager: AlarmManager? = context.getSystemService(AlarmManager::class.java)

    /** Before Android 12 exact alarms need no special access. */
    fun canScheduleExactAlarms(): Boolean {
        val manager = alarmManager ?: return false
        return !AndroidVersionUtils.hasExactAlarmSpecialAccess || manager.canScheduleExactAlarms()
    }

    /**
     * Arms the single transition alarm. Returns true when it is exact,
     * false when the inexact fallback had to be used.
     */
    fun scheduleTransition(triggerAtMillis: Long): Boolean {
        val manager = alarmManager ?: return false
        val operation = transitionIntent(PendingIntent.FLAG_UPDATE_CURRENT)!!
        return if (canScheduleExactAlarms()) {
            try {
                manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, operation)
                true
            } catch (_: SecurityException) {
                // The special access was revoked between the check and the
                // call. Fall back to the inexact alarm; the caller reports
                // that the alarm is not exact.
                manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, operation)
                false
            }
        } else {
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, operation)
            false
        }
    }

    fun cancelTransition() {
        val existing = transitionIntent(PendingIntent.FLAG_NO_CREATE) ?: return
        alarmManager?.cancel(existing)
        existing.cancel()
    }

    /** Keeps (or starts) the periodic fallback reconciliation. */
    fun ensurePeriodicReconciliation() {
        val request = PeriodicWorkRequestBuilder<MdmScheduleSyncWorker>(
            PERIODIC_INTERVAL_MINUTES,
            TimeUnit.MINUTES,
        ).build()
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            PERIODIC_WORK_NAME,
            ExistingPeriodicWorkPolicy.KEEP,
            request,
        )
    }

    fun cancelPeriodicReconciliation() {
        WorkManager.getInstance(context).cancelUniqueWork(PERIODIC_WORK_NAME)
    }

    private fun transitionIntent(flag: Int): PendingIntent? {
        val intent = Intent(context, MdmAlarmReceiver::class.java)
            .setAction(MdmAlarmReceiver.ACTION_SCHEDULE_TRANSITION)
        return PendingIntent.getBroadcast(
            context,
            TRANSITION_REQUEST_CODE,
            intent,
            flag or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private companion object {
        const val TRANSITION_REQUEST_CODE = 7001
        const val PERIODIC_WORK_NAME = "mdm_schedule_reconciliation"

        /** WorkManager's minimum period. */
        const val PERIODIC_INTERVAL_MINUTES = 15L
    }
}
