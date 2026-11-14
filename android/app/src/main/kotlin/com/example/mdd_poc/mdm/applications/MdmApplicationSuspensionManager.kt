package com.example.mdd_poc.mdm.applications

import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes

/**
 * Suspends and unsuspends packages with
 * `DevicePolicyManager.setPackagesSuspended()`.
 *
 * A suspended package stays installed and visible but cannot be started;
 * this is different from hiding, disabling or uninstalling it. Android
 * decides which packages may be suspended and returns the ones it refused;
 * that list is the source of truth for the result.
 */
class MdmApplicationSuspensionManager(
    private val adminManager: MdmAdminManager,
    private val packageManager: MdmPackageManager,
) {
    data class Failure(val errorCode: String, val message: String)

    /** Per-package outcome of a batch operation. */
    data class BatchResult(val succeeded: List<String>, val failed: Map<String, Failure>)

    fun suspendApplication(packageName: String) = applySingle(packageName, suspended = true)

    fun unsuspendApplication(packageName: String) = applySingle(packageName, suspended = false)

    fun suspendApplications(packageNames: List<String>): BatchResult =
        setSuspended(packageNames, suspended = true)

    fun unsuspendApplications(packageNames: List<String>): BatchResult =
        setSuspended(packageNames, suspended = false)

    /** Real suspension state of an installed package. */
    fun getApplicationSuspensionStatus(packageName: String): Boolean {
        MdmPackageNameValidator.require(packageName)
        val info = packageManager.requireInstalled(packageName)
        return info.applicationInfo?.let(packageManager::isSuspended) ?: false
    }

    private fun applySingle(packageName: String, suspended: Boolean) {
        val result = setSuspended(listOf(packageName), suspended)
        result.failed[packageName]?.let { throw MdmException(it.errorCode, it.message) }
        // Confirm against the device rather than trusting the call.
        if (getApplicationSuspensionStatus(packageName) != suspended) {
            throw MdmException(
                ErrorCodes.OPERATION_FAILED,
                "Android reported success but $packageName is " +
                    (if (suspended) "not suspended" else "still suspended"),
            )
        }
    }

    /**
     * Idempotent: applying the state a package already has succeeds.
     * Requires Device Owner; throws `DEVICE_OWNER_REQUIRED` otherwise.
     */
    private fun setSuspended(packageNames: List<String>, suspended: Boolean): BatchResult {
        val devicePolicyManager = adminManager.requireDeviceOwner()
        val failed = LinkedHashMap<String, Failure>()
        val eligible = packageNames.distinct().filter { name ->
            val reason = ineligibility(name, suspended)
            if (reason != null) failed[name] = reason
            reason == null
        }
        if (eligible.isNotEmpty()) {
            val refused = devicePolicyManager.setPackagesSuspended(
                adminManager.adminComponent,
                eligible.toTypedArray(),
                suspended,
            )
            refused.forEach { name ->
                failed[name] = Failure(
                    ErrorCodes.PACKAGE_NOT_SUSPENDABLE,
                    "Android refused to ${if (suspended) "suspend" else "unsuspend"} $name. " +
                        "Packages the system depends on (for example the launcher, package " +
                        "installer, dialer or other device admins) cannot be suspended.",
                )
            }
        }
        return BatchResult(succeeded = eligible.filterNot(failed::containsKey), failed = failed)
    }

    private fun ineligibility(packageName: String, suspended: Boolean): Failure? = when {
        !MdmPackageNameValidator.isValid(packageName) ->
            Failure(ErrorCodes.INVALID_ARGUMENT, "\"$packageName\" is not a valid package name")
        packageManager.getPackageInfoOrNull(packageName, includeHidden = true) == null ->
            Failure(ErrorCodes.PACKAGE_NOT_FOUND, "$packageName is not installed on this device")
        suspended && packageName == packageManager.ownPackageName ->
            Failure(
                ErrorCodes.PACKAGE_NOT_SUSPENDABLE,
                "The device management application cannot suspend itself",
            )
        else -> null
    }
}
