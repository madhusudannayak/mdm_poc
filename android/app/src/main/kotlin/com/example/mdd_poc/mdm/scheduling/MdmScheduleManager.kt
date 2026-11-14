package com.example.mdd_poc.mdm.scheduling

import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.applications.MdmApplicationPolicyStore
import com.example.mdd_poc.mdm.applications.MdmApplicationSuspensionManager
import com.example.mdd_poc.mdm.applications.MdmPackageManager
import com.example.mdd_poc.mdm.applications.MdmPackageNameValidator
import com.example.mdd_poc.mdm.models.ApplicationSchedule
import com.example.mdd_poc.mdm.models.ApplicationScheduleStatus
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.models.ScheduleSyncReport
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes
import com.example.mdd_poc.mdm.utils.MdmLogger
import java.util.TimeZone
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

/**
 * Time-based application restrictions.
 *
 * The manager never tracks "what it did last". Every pass ([synchronize])
 * recomputes from scratch what each scheduled package should be right now
 * and makes the device match, then arms one alarm for the next change. The
 * same pass therefore serves alarms, reboot, time and time-zone changes,
 * app start and the manual sync button, and recovers missed transitions.
 *
 * Desired state of a package:
 *   suspended = on the organization's blocklist
 *               OR (has enabled schedules AND outside all allowed windows)
 *
 * So removing or disabling a schedule releases the application unless the
 * blocklist still prohibits it, and a blocklisted application is never
 * released by a schedule.
 */
class MdmScheduleManager(
    private val repository: MdmScheduleRepository,
    private val adminManager: MdmAdminManager,
    private val packageManager: MdmPackageManager,
    private val suspensionManager: MdmApplicationSuspensionManager,
    private val policyStore: MdmApplicationPolicyStore,
    private val alarmScheduler: MdmAlarmScheduler,
    private val logger: MdmLogger,
    private val currentTimeMillis: () -> Long = System::currentTimeMillis,
    private val currentTimeZone: () -> TimeZone = TimeZone::getDefault,
) {
    private val mutex = Mutex()

    // --- Queries ----------------------------------------------------------

    suspend fun getApplicationSchedules(): List<ApplicationScheduleStatus> {
        val schedules = repository.getAll()
        val now = currentTimeMillis()
        val zone = currentTimeZone()
        val byPackage = schedules.groupBy { it.packageName }
        return schedules.map { schedule ->
            val evaluation = MdmScheduleEvaluator.evaluate(
                byPackage.getValue(schedule.packageName),
                MdmScheduleClock.weekTimeAt(now, zone),
            )
            val info = packageManager.getPackageInfoOrNull(schedule.packageName, includeHidden = true)
                ?.applicationInfo
            ApplicationScheduleStatus(
                schedule = schedule,
                applicationName = info?.let(packageManager::loadLabel),
                isWithinAllowedWindow = evaluation.isAllowedNow,
                isApplicationSuspended = info?.let(packageManager::isSuspended),
                nextTransitionAt = evaluation.nextTransition?.let {
                    MdmScheduleClock.transitionTimeMillis(now, zone, it)
                },
            )
        }
    }

    /**
     * True when enabled schedules currently require [packageName] to be
     * suspended. Used so that "allow" never releases a time-restricted app.
     */
    suspend fun isRestrictedNow(packageName: String): Boolean {
        val schedules = repository.getAll().filter { it.packageName == packageName }
        val now = MdmScheduleClock.weekTimeAt(currentTimeMillis(), currentTimeZone())
        return !MdmScheduleEvaluator.evaluate(schedules, now).isAllowedNow
    }

    // --- Changes ----------------------------------------------------------

    suspend fun saveApplicationSchedule(draft: ApplicationSchedule): ApplicationScheduleStatus {
        validate(draft)
        val saved = repository.insert(draft)
        enforceOrRollBack(saved.packageName, "schedule.save") { repository.delete(saved.id) }
        return statusOf(saved.id)
    }

    suspend fun updateApplicationSchedule(schedule: ApplicationSchedule): ApplicationScheduleStatus {
        validate(schedule)
        val previous = requireSchedule(schedule.id)
        repository.update(schedule)
        enforceOrRollBack(schedule.packageName, "schedule.update") { repository.update(previous) }
        if (previous.packageName != schedule.packageName) reconcilePackages(listOf(previous.packageName))
        return statusOf(schedule.id)
    }

    suspend fun setApplicationScheduleEnabled(id: Long, enabled: Boolean) {
        val previous = requireSchedule(id)
        if (previous.enabled == enabled) return
        if (enabled) adminManager.requireDeviceOwner()
        repository.update(previous.copy(enabled = enabled))
        enforceOrRollBack(previous.packageName, "schedule.setEnabled") { repository.update(previous) }
    }

    /**
     * Deletes the schedule and immediately restores the application to the
     * state its remaining policies require.
     */
    suspend fun removeApplicationSchedule(id: Long) {
        val removed = requireSchedule(id)
        repository.delete(id)
        val report = synchronize("schedule.remove", extraPackages = listOf(removed.packageName))
        report.failures.firstOrNull { it.packageName == removed.packageName }?.let {
            throw MdmException(
                it.errorCode,
                "The schedule was removed, but the application state could not be restored: " +
                    it.message,
            )
        }
    }

    // --- Reconciliation ---------------------------------------------------

    /**
     * Makes every scheduled package match its desired state and arms the
     * next transition. Idempotent and safe to call at any time.
     *
     * [extraPackages] are reconciled even if they no longer have schedules
     * (used right after a schedule is removed).
     */
    suspend fun synchronize(
        trigger: String,
        extraPackages: List<String> = emptyList(),
    ): ScheduleSyncReport = mutex.withLock {
        val requestedAt = currentTimeMillis()
        val schedules = repository.getAll()
        val byPackage = schedules.groupBy { it.packageName }
        val packages = (byPackage.keys + extraPackages).distinct()
        val zone = currentTimeZone()
        val now = MdmScheduleClock.weekTimeAt(requestedAt, zone)
        val isDeviceOwner = adminManager.isDeviceOwner()

        val changed = mutableListOf<String>()
        val failures = mutableListOf<ScheduleSyncReport.Failure>()
        var nextTransitionAt: Long? = null

        for (packageName in packages) {
            val evaluation = MdmScheduleEvaluator.evaluate(byPackage[packageName].orEmpty(), now)
            evaluation.nextTransition?.let { transition ->
                val at = MdmScheduleClock.transitionTimeMillis(requestedAt, zone, transition)
                nextTransitionAt = minOf(nextTransitionAt ?: at, at)
            }
            if (!isDeviceOwner) continue
            reconcile(packageName, evaluation, changed, failures)
        }

        if (!isDeviceOwner && packages.isNotEmpty()) {
            // Without ownership nothing can be enforced, and Android has
            // already lifted any suspension this app applied as owner.
            failures += packages.map {
                ScheduleSyncReport.Failure(
                    it,
                    ErrorCodes.DEVICE_OWNER_REQUIRED,
                    "Device Owner privileges required",
                )
            }
        }

        val exact = armWakeUps(nextTransitionAt, hasEnabledSchedules = schedules.any { it.enabled })
        logger.record(
            operationName = "schedule.sync[$trigger]",
            requestTimestamp = requestedAt,
            success = failures.isEmpty(),
            errorCode = failures.firstOrNull()?.errorCode,
            errorMessage = failures.takeIf { it.isNotEmpty() }
                ?.joinToString("; ") { "${it.packageName}: ${it.message}" },
        )
        ScheduleSyncReport(
            trigger = trigger,
            isDeviceOwner = isDeviceOwner,
            evaluatedPackages = packages.size,
            changedPackages = changed,
            failures = failures,
            nextTransitionAt = nextTransitionAt,
            exactAlarmScheduled = exact,
        )
    }

    private fun reconcile(
        packageName: String,
        evaluation: MdmScheduleEvaluator.Evaluation,
        changed: MutableList<String>,
        failures: MutableList<ScheduleSyncReport.Failure>,
    ) {
        val applicationInfo = packageManager
            .getPackageInfoOrNull(packageName, includeHidden = true)?.applicationInfo
            // Uninstalled: nothing to enforce. The schedule is kept so it
            // applies again if the application is reinstalled.
            ?: return
        val shouldBeSuspended =
            packageName in policyStore.blockedPackages || !evaluation.isAllowedNow
        if (packageManager.isSuspended(applicationInfo) == shouldBeSuspended) return

        val requestedAt = currentTimeMillis()
        val failure = try {
            val result = if (shouldBeSuspended) {
                suspensionManager.suspendApplications(listOf(packageName))
            } else {
                suspensionManager.unsuspendApplications(listOf(packageName))
            }
            result.failed[packageName]
                ?.let { ScheduleSyncReport.Failure(packageName, it.errorCode, it.message) }
        } catch (error: MdmException) {
            ScheduleSyncReport.Failure(packageName, error.errorCode, error.message)
        } catch (error: SecurityException) {
            ScheduleSyncReport.Failure(
                packageName,
                ErrorCodes.SECURITY_EXCEPTION,
                error.message ?: "Android denied the operation",
            )
        }
        if (failure == null) changed += packageName else failures += failure
        logger.record(
            operationName = if (shouldBeSuspended) "schedule.suspend" else "schedule.unsuspend",
            requestTimestamp = requestedAt,
            success = failure == null,
            packageName = packageName,
            errorCode = failure?.errorCode,
            errorMessage = failure?.message,
        )
    }

    /** Returns true when an exact transition alarm is armed. */
    private fun armWakeUps(nextTransitionAt: Long?, hasEnabledSchedules: Boolean): Boolean {
        if (hasEnabledSchedules) {
            alarmScheduler.ensurePeriodicReconciliation()
        } else {
            alarmScheduler.cancelPeriodicReconciliation()
        }
        if (nextTransitionAt == null) {
            alarmScheduler.cancelTransition()
            return false
        }
        return alarmScheduler.scheduleTransition(nextTransitionAt)
    }

    /**
     * Applies a just-stored change. If the device refuses to enforce it for
     * [packageName], [rollBack] restores the previous schedule, the device
     * is reconciled again and the refusal is reported to the caller.
     */
    private suspend fun enforceOrRollBack(
        packageName: String,
        trigger: String,
        rollBack: suspend () -> Unit,
    ) {
        val failure = synchronize(trigger).failures.firstOrNull { it.packageName == packageName }
            ?: return
        rollBack()
        synchronize("$trigger.rollback", extraPackages = listOf(packageName))
        throw MdmException(failure.errorCode, failure.message)
    }

    private suspend fun reconcilePackages(packages: List<String>) {
        synchronize("schedule.reconcile", extraPackages = packages)
    }

    private fun validate(schedule: ApplicationSchedule) {
        adminManager.requireDeviceOwner()
        MdmPackageNameValidator.require(schedule.packageName)
        MdmScheduleEvaluator.validate(
            schedule.startMinuteOfDay,
            schedule.endMinuteOfDay,
            schedule.daysOfWeek,
        )?.let { throw MdmException(ErrorCodes.INVALID_ARGUMENT, it) }
        packageManager.requireInstalled(schedule.packageName)
        if (schedule.packageName == packageManager.ownPackageName) {
            throw MdmException(
                ErrorCodes.PACKAGE_NOT_SUSPENDABLE,
                "The device management application cannot be time-restricted",
            )
        }
    }

    private suspend fun requireSchedule(id: Long): ApplicationSchedule =
        repository.getById(id)
            ?: throw MdmException(ErrorCodes.SCHEDULE_NOT_FOUND, "Schedule $id does not exist")

    private suspend fun statusOf(id: Long): ApplicationScheduleStatus =
        getApplicationSchedules().firstOrNull { it.schedule.id == id }
            ?: throw MdmException(ErrorCodes.SCHEDULE_NOT_FOUND, "Schedule $id does not exist")
}
