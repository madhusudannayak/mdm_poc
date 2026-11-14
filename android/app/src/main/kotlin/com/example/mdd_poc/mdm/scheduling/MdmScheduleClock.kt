package com.example.mdd_poc.mdm.scheduling

import java.util.Calendar
import java.util.TimeZone

/**
 * Converts between epoch time and the local weekly wall clock.
 *
 * Schedules are defined in wall-clock time, so every conversion goes
 * through the device's CURRENT time zone. Transition instants are built
 * from calendar fields rather than by adding minutes, which keeps them
 * correct across daylight-saving changes.
 */
object MdmScheduleClock {

    fun weekTimeAt(epochMillis: Long, timeZone: TimeZone): MdmScheduleEvaluator.WeekTime {
        val calendar = Calendar.getInstance(timeZone).apply { timeInMillis = epochMillis }
        return MdmScheduleEvaluator.WeekTime(
            dayOfWeek = isoDayOfWeek(calendar.get(Calendar.DAY_OF_WEEK)),
            minuteOfDay = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE),
        )
    }

    /** Epoch time of [transition], counted from the local day of [nowMillis]. */
    fun transitionTimeMillis(
        nowMillis: Long,
        timeZone: TimeZone,
        transition: MdmScheduleEvaluator.Transition,
    ): Long {
        val calendar = Calendar.getInstance(timeZone).apply {
            timeInMillis = nowMillis
            add(Calendar.DAY_OF_YEAR, transition.daysAhead)
            set(Calendar.HOUR_OF_DAY, transition.minuteOfDay / 60)
            set(Calendar.MINUTE, transition.minuteOfDay % 60)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        // Normally the transition is in the future and is used as is. A
        // wall-clock time skipped or repeated by a DST change can resolve to
        // "now or earlier"; then re-evaluate shortly instead of looping.
        val target = calendar.timeInMillis
        return if (target > nowMillis) target else nowMillis + RETRY_DELAY_MILLIS
    }

    /** Calendar uses Sunday = 1; ISO uses Monday = 1 .. Sunday = 7. */
    private fun isoDayOfWeek(calendarDay: Int): Int =
        if (calendarDay == Calendar.SUNDAY) 7 else calendarDay - 1

    private const val RETRY_DELAY_MILLIS = 60_000L
}
