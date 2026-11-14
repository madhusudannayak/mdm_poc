package com.example.mdd_poc.mdm.models

/**
 * A window during which an application is allowed to run.
 *
 * Times are minutes since local midnight (0..1439). When [endMinuteOfDay]
 * is not after [startMinuteOfDay] the window crosses midnight and ends on
 * the following day. [daysOfWeek] uses ISO numbering (1 = Monday ..
 * 7 = Sunday) and names the day on which the window starts.
 */
data class ApplicationSchedule(
    val id: Long,
    val packageName: String,
    val startMinuteOfDay: Int,
    val endMinuteOfDay: Int,
    val daysOfWeek: Set<Int>,
    val enabled: Boolean,
)

/** A schedule plus the live state of the application it controls. */
data class ApplicationScheduleStatus(
    val schedule: ApplicationSchedule,
    /** Null when the package is no longer installed. */
    val applicationName: String?,
    /** True when the package's enabled schedules allow it right now. */
    val isWithinAllowedWindow: Boolean,
    /** Real suspension state; null when the package is not installed. */
    val isApplicationSuspended: Boolean?,
    /** Next time the package's allowed state changes; null if it never does. */
    val nextTransitionAt: Long?,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "id" to schedule.id,
        "packageName" to schedule.packageName,
        "startMinuteOfDay" to schedule.startMinuteOfDay,
        "endMinuteOfDay" to schedule.endMinuteOfDay,
        "daysOfWeek" to schedule.daysOfWeek.sorted(),
        "enabled" to schedule.enabled,
        "applicationName" to applicationName,
        "isWithinAllowedWindow" to isWithinAllowedWindow,
        "isApplicationSuspended" to isApplicationSuspended,
        "nextTransitionAt" to nextTransitionAt,
    )
}

/** Outcome of one reconciliation pass. */
data class ScheduleSyncReport(
    val trigger: String,
    val isDeviceOwner: Boolean,
    val evaluatedPackages: Int,
    val changedPackages: List<String>,
    val failures: List<Failure>,
    val nextTransitionAt: Long?,
    val exactAlarmScheduled: Boolean,
) {
    data class Failure(val packageName: String, val errorCode: String, val message: String)

    fun toMap(): Map<String, Any?> = mapOf(
        "trigger" to trigger,
        "isDeviceOwner" to isDeviceOwner,
        "evaluatedPackages" to evaluatedPackages,
        "changedPackages" to changedPackages,
        "failures" to failures.map {
            mapOf(
                "packageName" to it.packageName,
                "errorCode" to it.errorCode,
                "message" to it.message,
            )
        },
        "nextTransitionAt" to nextTransitionAt,
        "exactAlarmScheduled" to exactAlarmScheduled,
    )
}
