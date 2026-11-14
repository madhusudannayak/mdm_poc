package com.example.mdd_poc.mdm.scheduling

import com.example.mdd_poc.mdm.models.ApplicationSchedule
import com.example.mdd_poc.mdm.scheduling.MdmScheduleEvaluator.WeekTime
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class MdmScheduleEvaluatorTest {
    private val monday = 1
    private val tuesday = 2
    private val friday = 5
    private val saturday = 6
    private val sunday = 7

    private fun schedule(
        start: String,
        end: String,
        days: Set<Int>,
        enabled: Boolean = true,
    ) = ApplicationSchedule(
        id = 1,
        packageName = "com.google.android.youtube",
        startMinuteOfDay = minutes(start),
        endMinuteOfDay = minutes(end),
        daysOfWeek = days,
        enabled = enabled,
    )

    private fun minutes(time: String): Int = time.split(":").let { it[0].toInt() * 60 + it[1].toInt() }

    private fun at(day: Int, time: String) = WeekTime(day, minutes(time))

    private val weekdays = setOf(1, 2, 3, 4, 5)
    private val nineToSix = listOf(schedule("09:00", "18:00", weekdays))

    @Test
    fun `daytime window - before, inside and after`() {
        assertFalse(MdmScheduleEvaluator.evaluate(nineToSix, at(monday, "08:59")).isAllowedNow)
        assertTrue(MdmScheduleEvaluator.evaluate(nineToSix, at(monday, "09:00")).isAllowedNow)
        assertTrue(MdmScheduleEvaluator.evaluate(nineToSix, at(monday, "17:59")).isAllowedNow)
        assertFalse(MdmScheduleEvaluator.evaluate(nineToSix, at(monday, "18:00")).isAllowedNow)
        assertFalse(MdmScheduleEvaluator.evaluate(nineToSix, at(monday, "23:30")).isAllowedNow)
    }

    @Test
    fun `days not selected stay restricted`() {
        assertFalse(MdmScheduleEvaluator.evaluate(nineToSix, at(saturday, "12:00")).isAllowedNow)
    }

    @Test
    fun `next transition before the window is the start today`() {
        val transition = MdmScheduleEvaluator.evaluate(nineToSix, at(monday, "07:30")).nextTransition!!
        assertEquals(0, transition.daysAhead)
        assertEquals(minutes("09:00"), transition.minuteOfDay)
        assertTrue(transition.becomesAllowed)
    }

    @Test
    fun `next transition inside the window is the end today`() {
        val transition = MdmScheduleEvaluator.evaluate(nineToSix, at(monday, "10:00")).nextTransition!!
        assertEquals(0, transition.daysAhead)
        assertEquals(minutes("18:00"), transition.minuteOfDay)
        assertFalse(transition.becomesAllowed)
    }

    @Test
    fun `next transition after friday evening skips the weekend`() {
        val transition = MdmScheduleEvaluator.evaluate(nineToSix, at(friday, "19:00")).nextTransition!!
        assertEquals(3, transition.daysAhead)
        assertEquals(minutes("09:00"), transition.minuteOfDay)
        assertTrue(transition.becomesAllowed)
    }

    @Test
    fun `overnight window crosses midnight into the next day`() {
        val overnight = listOf(schedule("22:00", "06:00", setOf(monday)))
        assertFalse(MdmScheduleEvaluator.evaluate(overnight, at(monday, "21:59")).isAllowedNow)
        assertTrue(MdmScheduleEvaluator.evaluate(overnight, at(monday, "23:00")).isAllowedNow)
        assertTrue(MdmScheduleEvaluator.evaluate(overnight, at(tuesday, "05:59")).isAllowedNow)
        assertFalse(MdmScheduleEvaluator.evaluate(overnight, at(tuesday, "06:00")).isAllowedNow)
        // The window belongs to Monday: Tuesday night is not allowed.
        assertFalse(MdmScheduleEvaluator.evaluate(overnight, at(tuesday, "23:00")).isAllowedNow)
    }

    @Test
    fun `overnight transition lands on the following day`() {
        val overnight = listOf(schedule("22:00", "06:00", setOf(monday)))
        val transition = MdmScheduleEvaluator.evaluate(overnight, at(monday, "23:00")).nextTransition!!
        assertEquals(1, transition.daysAhead)
        assertEquals(minutes("06:00"), transition.minuteOfDay)
        assertFalse(transition.becomesAllowed)
    }

    @Test
    fun `sunday overnight window wraps into monday`() {
        val overnight = listOf(schedule("22:00", "06:00", setOf(sunday)))
        assertTrue(MdmScheduleEvaluator.evaluate(overnight, at(monday, "03:00")).isAllowedNow)
        assertFalse(MdmScheduleEvaluator.evaluate(overnight, at(monday, "06:00")).isAllowedNow)
    }

    @Test
    fun `overlapping schedules resolve as a union`() {
        val overlapping = listOf(
            schedule("09:00", "12:00", setOf(monday)),
            schedule("11:00", "15:00", setOf(monday)),
        )
        assertTrue(MdmScheduleEvaluator.evaluate(overlapping, at(monday, "11:30")).isAllowedNow)
        assertTrue(MdmScheduleEvaluator.evaluate(overlapping, at(monday, "14:00")).isAllowedNow)
        // No transition at 12:00: the second window still allows.
        val transition = MdmScheduleEvaluator.evaluate(overlapping, at(monday, "09:30")).nextTransition!!
        assertEquals(minutes("15:00"), transition.minuteOfDay)
    }

    @Test
    fun `disabled schedules do not restrict`() {
        val disabled = listOf(schedule("09:00", "18:00", weekdays, enabled = false))
        val evaluation = MdmScheduleEvaluator.evaluate(disabled, at(monday, "03:00"))
        assertFalse(evaluation.isTimeRestricted)
        assertTrue(evaluation.isAllowedNow)
        assertNull(evaluation.nextTransition)
    }

    @Test
    fun `no schedules means no restriction`() {
        val evaluation = MdmScheduleEvaluator.evaluate(emptyList(), at(monday, "03:00"))
        assertFalse(evaluation.isTimeRestricted)
        assertTrue(evaluation.isAllowedNow)
    }

    @Test
    fun `validation rejects bad input`() {
        assertNull(MdmScheduleEvaluator.validate(540, 1080, listOf(1, 2)))
        assertNotNull(MdmScheduleEvaluator.validate(540, 540, listOf(1)))
        assertNotNull(MdmScheduleEvaluator.validate(-1, 100, listOf(1)))
        assertNotNull(MdmScheduleEvaluator.validate(0, 1440, listOf(1)))
        assertNotNull(MdmScheduleEvaluator.validate(540, 1080, emptyList()))
        assertNotNull(MdmScheduleEvaluator.validate(540, 1080, listOf(0)))
        assertNotNull(MdmScheduleEvaluator.validate(540, 1080, listOf(1, 1)))
    }
}
