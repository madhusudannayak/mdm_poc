package com.example.mdd_poc.mdm.scheduling

import com.example.mdd_poc.mdm.models.ApplicationSchedule

/**
 * Central, pure evaluation of time-based restrictions.
 *
 * All enabled schedules of a package are merged into one weekly timeline
 * (minute resolution). Overlapping schedules therefore resolve as a union:
 * the application is allowed whenever at least one window allows it.
 * A package without enabled schedules is not time-restricted at all.
 */
object MdmScheduleEvaluator {
    const val MINUTES_PER_DAY = 24 * 60
    const val MINUTES_PER_WEEK = 7 * MINUTES_PER_DAY

    /** A point on the weekly wall clock. [dayOfWeek] is ISO, 1 = Monday. */
    data class WeekTime(val dayOfWeek: Int, val minuteOfDay: Int) {
        val minuteOfWeek: Int get() = (dayOfWeek - 1) * MINUTES_PER_DAY + minuteOfDay
    }

    /** The next change of the allowed state, relative to the evaluated time. */
    data class Transition(val daysAhead: Int, val minuteOfDay: Int, val becomesAllowed: Boolean)

    data class Evaluation(
        /** False when the package has no enabled schedules. */
        val isTimeRestricted: Boolean,
        val isAllowedNow: Boolean,
        /** Null when the state never changes (no schedule, or always allowed). */
        val nextTransition: Transition?,
    )

    /** Validation shared by save and update. Returns an error text or null. */
    fun validate(startMinuteOfDay: Int, endMinuteOfDay: Int, daysOfWeek: Collection<Int>): String? =
        when {
            startMinuteOfDay !in 0 until MINUTES_PER_DAY ||
                endMinuteOfDay !in 0 until MINUTES_PER_DAY ->
                "Schedule times must be between 00:00 and 23:59"
            startMinuteOfDay == endMinuteOfDay -> "Schedule start and end times must differ"
            daysOfWeek.isEmpty() -> "Select at least one day"
            daysOfWeek.any { it !in 1..7 } -> "Days must be between 1 (Monday) and 7 (Sunday)"
            daysOfWeek.toSet().size != daysOfWeek.size -> "Days must be unique"
            else -> null
        }

    /** Evaluates the schedules of ONE package at [now]. */
    fun evaluate(schedules: List<ApplicationSchedule>, now: WeekTime): Evaluation {
        val enabled = schedules.filter { it.enabled }
        if (enabled.isEmpty()) {
            return Evaluation(isTimeRestricted = false, isAllowedNow = true, nextTransition = null)
        }
        val timeline = buildTimeline(enabled)
        val nowIndex = now.minuteOfWeek
        val allowedNow = timeline[nowIndex]
        val minutesAhead = (1..MINUTES_PER_WEEK).firstOrNull { offset ->
            timeline[(nowIndex + offset) % MINUTES_PER_WEEK] != allowedNow
        }
        val transition = minutesAhead?.let { offset ->
            val absoluteMinuteOfDay = now.minuteOfDay + offset
            Transition(
                daysAhead = absoluteMinuteOfDay / MINUTES_PER_DAY,
                minuteOfDay = absoluteMinuteOfDay % MINUTES_PER_DAY,
                becomesAllowed = !allowedNow,
            )
        }
        return Evaluation(isTimeRestricted = true, isAllowedNow = allowedNow, nextTransition = transition)
    }

    /** One flag per minute of the week: true where any schedule allows. */
    private fun buildTimeline(schedules: List<ApplicationSchedule>): BooleanArray {
        val timeline = BooleanArray(MINUTES_PER_WEEK)
        for (schedule in schedules) {
            // A window ending at or before its start runs into the next day.
            val length = Math.floorMod(
                schedule.endMinuteOfDay - schedule.startMinuteOfDay,
                MINUTES_PER_DAY,
            )
            for (day in schedule.daysOfWeek) {
                val start = (day - 1) * MINUTES_PER_DAY + schedule.startMinuteOfDay
                for (offset in 0 until length) {
                    // Sunday-night windows wrap around into Monday.
                    timeline[(start + offset) % MINUTES_PER_WEEK] = true
                }
            }
        }
        return timeline
    }
}
