package com.example.mdd_poc.mdm.channel

import android.util.Log
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.admin.MdmProvisioningManager
import com.example.mdd_poc.mdm.applications.MdmApplicationManager
import com.example.mdd_poc.mdm.applications.MdmPackageNameValidator
import com.example.mdd_poc.mdm.device.MdmDeviceInformationManager
import com.example.mdd_poc.mdm.device.MdmDeviceManager
import com.example.mdd_poc.mdm.device.MdmSecurityManager
import com.example.mdd_poc.mdm.models.ApplicationSchedule
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.models.MdmResult
import com.example.mdd_poc.mdm.policy.MdmInstallationManager
import com.example.mdd_poc.mdm.scheduling.MdmScheduleManager
import com.example.mdd_poc.mdm.utils.MdmConstants
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes
import com.example.mdd_poc.mdm.utils.MdmConstants.Methods
import com.example.mdd_poc.mdm.utils.MdmLogger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

private typealias MethodOperation = suspend (MethodCall) -> MdmResult

/**
 * Routes channel calls to the native MDM services.
 *
 * Each operation runs off the main thread and always answers with the
 * standard [MdmResult] envelope. Failures are reported with a real error
 * code, never as a fake success. Methods of the contract that this build
 * does not implement yet answer `notImplemented`, which Flutter surfaces as
 * `NATIVE_METHOD_MISSING`.
 */
class MdmMethodHandler(
    private val adminManager: MdmAdminManager,
    private val provisioningManager: MdmProvisioningManager,
    private val deviceInformationManager: MdmDeviceInformationManager,
    private val deviceManager: MdmDeviceManager,
    private val applicationManager: MdmApplicationManager,
    private val scheduleManager: MdmScheduleManager,
    private val installationManager: MdmInstallationManager,
    private val securityManager: MdmSecurityManager,
    private val logger: MdmLogger,
    private val scope: CoroutineScope,
    private val workDispatcher: CoroutineDispatcher = Dispatchers.Default,
) : MethodChannel.MethodCallHandler {

    private val operations: Map<String, MethodOperation> = mapOf(
        // Device information
        Methods.GET_DEVICE_INFO to {
            MdmResult.success(deviceInformationManager.getDeviceInformation().toMap())
        },
        Methods.GET_ANDROID_VERSION to {
            MdmResult.success(deviceInformationManager.getAndroidVersion().toMap())
        },
        Methods.GET_DEVICE_MANAGEMENT_STATUS to {
            MdmResult.success(
                mapOf(
                    "managementMode" to adminManager.getManagementMode().name,
                    "isDeviceOwner" to adminManager.isDeviceOwner(),
                    "isProfileOwner" to adminManager.isProfileOwner(),
                    "isDeviceAdminActive" to adminManager.isDeviceAdminActive(),
                    "isDeviceAdminSupported" to adminManager.isDeviceAdminSupported(),
                    "adminComponent" to adminManager.adminComponent.flattenToShortString(),
                ),
            )
        },
        Methods.GET_DEVICE_ADMIN_STATUS to {
            MdmResult.success(
                mapOf(
                    "isActive" to adminManager.isDeviceAdminActive(),
                    "isSupported" to adminManager.isDeviceAdminSupported(),
                    "adminComponent" to adminManager.adminComponent.flattenToShortString(),
                ),
            )
        },
        Methods.GET_DEVICE_OWNER_STATUS to {
            MdmResult.success(
                mapOf(
                    "isDeviceOwner" to adminManager.isDeviceOwner(),
                    "isProfileOwner" to adminManager.isProfileOwner(),
                    "packageName" to adminManager.packageName,
                ),
            )
        },

        // Device provisioning
        Methods.IS_DEVICE_OWNER to {
            MdmResult.success(mapOf("isDeviceOwner" to adminManager.isDeviceOwner()))
        },
        Methods.IS_DEVICE_ADMIN_ACTIVE to {
            MdmResult.success(mapOf("isDeviceAdminActive" to adminManager.isDeviceAdminActive()))
        },
        Methods.GET_PROVISIONING_STATUS to {
            MdmResult.success(provisioningManager.getProvisioningStatus().toMap())
        },

        // Application management
        Methods.GET_INSTALLED_APPLICATIONS to { call ->
            val applications = applicationManager.getInstalledApplications(
                includeSystemApplications = call.optionalBoolean("includeSystemApplications") ?: true,
                includeIcons = call.optionalBoolean("includeIcons") ?: true,
            )
            MdmResult.success(applications.map { it.toMap() })
        },
        Methods.GET_APPLICATION_DETAILS to { call ->
            MdmResult.success(
                applicationManager.getApplicationDetails(call.requirePackageName()).toMap(),
            )
        },
        Methods.SUSPEND_APPLICATION to { call ->
            applicationManager.blockApplication(call.requirePackageName())
            MdmResult.success(message = "Application suspended")
        },
        Methods.UNSUSPEND_APPLICATION to { call ->
            applicationManager.allowApplication(call.requirePackageName())
            MdmResult.success(message = "Application unsuspended")
        },
        Methods.IS_APPLICATION_SUSPENDED to { call ->
            val suspended = applicationManager.isApplicationSuspended(call.requirePackageName())
            MdmResult.success(mapOf("isSuspended" to suspended))
        },
        Methods.SET_APPLICATION_HIDDEN to { call ->
            applicationManager.setApplicationHidden(call.requirePackageName(), hidden = true)
            MdmResult.success(message = "Application hidden")
        },
        Methods.SET_APPLICATION_UNHIDDEN to { call ->
            applicationManager.setApplicationHidden(call.requirePackageName(), hidden = false)
            MdmResult.success(message = "Application unhidden")
        },

        Methods.SET_APPLICATION_UNINSTALL_BLOCKED to { call ->
            val blocked = call.requireBoolean("blocked")
            installationManager.setApplicationUninstallBlocked(call.requirePackageName(), blocked)
            MdmResult.success(message = if (blocked) "Uninstall blocked" else "Uninstall allowed")
        },

        // Installation management
        Methods.SET_APPLICATION_INSTALLATION_RESTRICTION to { call ->
            val status = installationManager
                .setApplicationInstallationRestriction(call.requireBoolean("enabled"))
            MdmResult.success(status.toMap())
        },
        Methods.SET_UNKNOWN_SOURCES_RESTRICTION to { call ->
            val status = installationManager
                .setUnknownSourcesRestriction(call.requireBoolean("enabled"))
            MdmResult.success(status.toMap())
        },
        Methods.GET_INSTALLATION_RESTRICTION_STATUS to {
            MdmResult.success(installationManager.getInstallationRestrictionStatus().toMap())
        },

        // Device security
        Methods.LOCK_DEVICE to {
            securityManager.lockDevice()
            MdmResult.success(message = "Device locked")
        },
        Methods.WIPE_DEVICE to { call ->
            securityManager.wipeDevice(confirmed = call.optionalBoolean("confirmed") == true)
            // A device that really resets restarts and kills this process
            // before any reply is sent. Android does not report a reset it
            // failed to start (for example on emulator images without a
            // recovery partition), so still running after the grace period
            // means the reset did not happen.
            delay(WIPE_GRACE_PERIOD_MILLIS)
            throw MdmException(
                ErrorCodes.FACTORY_RESET_NOT_PERFORMED,
                "Android accepted the factory reset request, but the device did not restart. " +
                    "The reset was not performed. Some emulators cannot factory reset.",
            )
        },

        // Scheduling
        Methods.GET_APPLICATION_SCHEDULES to {
            MdmResult.success(scheduleManager.getApplicationSchedules().map { it.toMap() })
        },
        Methods.SAVE_APPLICATION_SCHEDULE to { call ->
            val saved = scheduleManager.saveApplicationSchedule(call.requireSchedule(requireId = false))
            MdmResult.success(saved.toMap(), "Schedule saved")
        },
        Methods.UPDATE_APPLICATION_SCHEDULE to { call ->
            val updated = scheduleManager.updateApplicationSchedule(call.requireSchedule(requireId = true))
            MdmResult.success(updated.toMap(), "Schedule updated")
        },
        Methods.REMOVE_APPLICATION_SCHEDULE to { call ->
            scheduleManager.removeApplicationSchedule(call.requireScheduleId())
            MdmResult.success(message = "Schedule removed")
        },
        Methods.ENABLE_APPLICATION_SCHEDULE to { call ->
            scheduleManager.setApplicationScheduleEnabled(call.requireScheduleId(), enabled = true)
            MdmResult.success(message = "Schedule enabled")
        },
        Methods.DISABLE_APPLICATION_SCHEDULE to { call ->
            scheduleManager.setApplicationScheduleEnabled(call.requireScheduleId(), enabled = false)
            MdmResult.success(message = "Schedule disabled")
        },
        Methods.SYNCHRONIZE_APPLICATION_SCHEDULES to {
            MdmResult.success(scheduleManager.synchronize("manual").toMap(), "Schedules synchronized")
        },

        // System
        Methods.GET_NATIVE_CAPABILITIES to {
            MdmResult.success(deviceManager.getNativeCapabilities(implementedMethods))
        },
        Methods.GET_NATIVE_LOGS to { call ->
            val limit = call.optionalPositiveInt("limit")
            MdmResult.success(logger.getEntries(limit).map { it.toMap() })
        },
        Methods.CHECK_NATIVE_PERMISSIONS to {
            MdmResult.success(deviceManager.checkNativePermissions())
        },
    )

    /** Methods this native build really handles. */
    val implementedMethods: Set<String> get() = operations.keys

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val operation = operations[call.method]
        if (operation == null) {
            Log.w(MdmConstants.LOG_TAG, "Method not implemented natively: ${call.method}")
            result.notImplemented()
            return
        }
        val requestedAt = System.currentTimeMillis()
        scope.launch {
            val outcome = withContext(workDispatcher) { execute(operation, call) }
            if (call.method !in UNLOGGED_METHODS) {
                logger.record(
                    operationName = call.method,
                    requestTimestamp = requestedAt,
                    success = outcome.success,
                    packageName = call.optionalString("packageName"),
                    errorCode = outcome.errorCode,
                    errorMessage = outcome.message.takeUnless { outcome.success },
                )
            }
            result.success(outcome.toMap())
        }
    }

    /** Runs [operation], converting every failure into a failure envelope. */
    private suspend fun execute(operation: MethodOperation, call: MethodCall): MdmResult = try {
        operation(call)
    } catch (error: CancellationException) {
        throw error
    } catch (error: MdmException) {
        MdmResult.failure(error.errorCode, error.message)
    } catch (error: SecurityException) {
        Log.e(MdmConstants.LOG_TAG, "${call.method} was denied by Android", error)
        MdmResult.failure(
            ErrorCodes.SECURITY_EXCEPTION,
            error.message ?: "Android denied this operation",
        )
    } catch (error: Exception) {
        Log.e(MdmConstants.LOG_TAG, "${call.method} failed", error)
        MdmResult.failure(
            ErrorCodes.OPERATION_FAILED,
            error.message ?: "${call.method} failed (${error.javaClass.simpleName})",
        )
    }

    private fun MethodCall.optionalString(key: String): String? =
        (arguments as? Map<*, *>)?.get(key) as? String

    private fun MethodCall.optionalBoolean(key: String): Boolean? =
        (arguments as? Map<*, *>)?.get(key) as? Boolean

    private fun MethodCall.requireBoolean(key: String): Boolean =
        optionalBoolean(key)
            ?: throw MdmException(ErrorCodes.INVALID_ARGUMENT, "\"$key\" must be true or false")

    private fun MethodCall.requirePackageName(): String =
        MdmPackageNameValidator.require(optionalString("packageName"))

    private fun MethodCall.argumentMap(): Map<*, *> =
        arguments as? Map<*, *>
            ?: throw MdmException(ErrorCodes.INVALID_ARGUMENT, "Arguments are required")

    private fun MethodCall.requireScheduleId(): Long =
        (argumentMap()["scheduleId"] as? Number)?.toLong()?.takeIf { it > 0 }
            ?: throw MdmException(ErrorCodes.INVALID_ARGUMENT, "A valid schedule id is required")

    /** Structural parsing only; value rules are enforced by the manager. */
    private fun MethodCall.requireSchedule(requireId: Boolean): ApplicationSchedule {
        val map = argumentMap()
        fun int(key: String): Int = (map[key] as? Number)?.toInt()
            ?: throw MdmException(ErrorCodes.INVALID_ARGUMENT, "\"$key\" must be a number")
        val id = (map["id"] as? Number)?.toLong() ?: 0L
        if (requireId && id <= 0) {
            throw MdmException(ErrorCodes.INVALID_ARGUMENT, "A persisted schedule id is required")
        }
        val days = (map["daysOfWeek"] as? List<*>)?.map {
            (it as? Number)?.toInt()
                ?: throw MdmException(ErrorCodes.INVALID_ARGUMENT, "\"daysOfWeek\" must be numbers")
        } ?: throw MdmException(ErrorCodes.INVALID_ARGUMENT, "\"daysOfWeek\" is required")
        if (days.toSet().size != days.size) {
            throw MdmException(ErrorCodes.INVALID_ARGUMENT, "Days must be unique")
        }
        return ApplicationSchedule(
            id = id,
            packageName = MdmPackageNameValidator.require(map["packageName"] as? String),
            startMinuteOfDay = int("startMinuteOfDay"),
            endMinuteOfDay = int("endMinuteOfDay"),
            daysOfWeek = days.toSet(),
            enabled = map["enabled"] as? Boolean ?: true,
        )
    }

    private fun MethodCall.optionalPositiveInt(key: String): Int? {
        val raw = (arguments as? Map<*, *>)?.get(key) ?: return null
        val value = (raw as? Number)?.toInt()
        if (value == null || value <= 0) {
            throw MdmException(ErrorCodes.INVALID_ARGUMENT, "\"$key\" must be a positive number")
        }
        return value
    }

    private companion object {
        /** Reading the log must not itself add log entries. */
        val UNLOGGED_METHODS = setOf(Methods.GET_NATIVE_LOGS)

        const val WIPE_GRACE_PERIOD_MILLIS = 30_000L
    }
}
