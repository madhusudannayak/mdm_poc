package com.example.mdd_poc.mdm.scheduling

import com.example.mdd_poc.mdm.scheduling.MdmScheduleEvaluator.Transition
import java.util.Calendar
import java.util.TimeZone
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class MdmScheduleClockTest {
    private val kolkata = TimeZone.getTimeZone("Asia/Kolkata")
    private val newYork = TimeZone.getTimeZone("America/New_York")
    private val utc = TimeZone.getTimeZone("UTC")

    private fun millis(zone: TimeZone, year: Int, month: Int, day: Int, hour: Int, minute: Int): Long =
        Calendar.getInstance(zone).apply {
            clear()
            set(year, month - 1, day, hour, minute, 0)
        }.timeInMillis

    @Test
    fun `week time uses iso days in the given zone`() {
        // 2026-11-16 is a Monday.
        val time = MdmScheduleClock.weekTimeAt(millis(kolkata, 2026, 11, 16, 9, 30), kolkata)
        assertEquals(1, time.dayOfWeek)
        assertEquals(9 * 60 + 30, time.minuteOfDay)

        val sunday = MdmScheduleClock.weekTimeAt(millis(kolkata, 2026, 11, 15, 0, 0), kolkata)
        assertEquals(7, sunday.dayOfWeek)
    }

    @Test
    fun `the same instant is a different wall time in another zone`() {
        val instant = millis(utc, 2026, 11, 16, 20, 0)
        assertEquals(1, MdmScheduleClock.weekTimeAt(instant, utc).dayOfWeek)
        // 20:00 UTC Monday is 01:30 Tuesday in Kolkata.
        val local = MdmScheduleClock.weekTimeAt(instant, kolkata)
        assertEquals(2, local.dayOfWeek)
        assertEquals(90, local.minuteOfDay)
    }

    @Test
    fun `transition time is built on the local calendar`() {
        val now = millis(kolkata, 2026, 11, 16, 7, 30)
        val at = MdmScheduleClock.transitionTimeMillis(
            now,
            kolkata,
            Transition(daysAhead = 0, minuteOfDay = 9 * 60, becomesAllowed = true),
        )
        assertEquals(millis(kolkata, 2026, 11, 16, 9, 0), at)
    }

    @Test
    fun `transition across a daylight saving change keeps the wall clock time`() {
        // US clocks go forward on 2026-03-08; that day has 23 hours.
        val now = millis(newYork, 2026, 3, 7, 20, 0)
        val at = MdmScheduleClock.transitionTimeMillis(
            now,
            newYork,
            Transition(daysAhead = 1, minuteOfDay = 9 * 60, becomesAllowed = true),
        )
        assertEquals(millis(newYork, 2026, 3, 8, 9, 0), at)
        assertEquals(12 * 60 * 60 * 1000L, at - now)
    }

    @Test
    fun `a transition seconds away is not delayed`() {
        val now = millis(kolkata, 2026, 11, 14, 8, 59) + 20_000
        val at = MdmScheduleClock.transitionTimeMillis(
            now,
            kolkata,
            Transition(daysAhead = 0, minuteOfDay = 9 * 60, becomesAllowed = true),
        )
        assertEquals(millis(kolkata, 2026, 11, 14, 9, 0), at)
    }

    @Test
    fun `transition is never in the past`() {
        val now = millis(utc, 2026, 11, 16, 9, 0) + 30_000
        val at = MdmScheduleClock.transitionTimeMillis(
            now,
            utc,
            Transition(daysAhead = 0, minuteOfDay = 9 * 60, becomesAllowed = true),
        )
        assertTrue(at > now)
    }
}
