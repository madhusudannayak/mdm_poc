package com.example.mdd_poc.mdm.channel

import android.util.Log
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.admin.MdmProvisioningManager
import com.example.mdd_poc.mdm.device.MdmDeviceInformationManager
import com.example.mdd_poc.mdm.device.MdmDeviceManager
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.models.MdmResult
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
    }
}
