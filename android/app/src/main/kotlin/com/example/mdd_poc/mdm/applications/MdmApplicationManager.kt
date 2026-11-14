package com.example.mdd_poc.mdm.applications

import android.content.pm.PackageInfo
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.models.ManagedApplication
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope

/**
 * Application inventory and application control.
 *
 * Blocking suspends the package and records it on the blocklist; allowing
 * records it on the allowlist and unsuspends it unless a time restriction
 * still applies. The list is only updated after Android has applied the
 * change.
 */
class MdmApplicationManager(
    private val adminManager: MdmAdminManager,
    private val packageManager: MdmPackageManager,
    private val suspensionManager: MdmApplicationSuspensionManager,
    private val policyStore: MdmApplicationPolicyStore,
    /** Whether enabled time schedules currently require suspension. */
    private val isTimeRestrictedNow: suspend (packageName: String) -> Boolean,
) {

    /** Packages are read in parallel; icon rendering dominates the cost. */
    suspend fun getInstalledApplications(
        includeSystemApplications: Boolean,
        includeIcons: Boolean,
    ): List<ManagedApplication> = coroutineScope {
        // Hidden packages are only meaningful (and only queryable) as owner.
        val isDeviceOwner = adminManager.isDeviceOwner()
        packageManager.getInstalledPackages(includeHidden = isDeviceOwner)
            .map { info ->
                async(Dispatchers.Default) {
                    toManagedApplication(info, includeIcons, isDeviceOwner)
                }
            }
            .awaitAll()
            .filterNotNull()
            .filter { includeSystemApplications || !it.isSystemApplication }
            .sortedBy { it.applicationName.lowercase() }
    }

    fun getApplicationDetails(packageName: String): ManagedApplication {
        MdmPackageNameValidator.require(packageName)
        val isDeviceOwner = adminManager.isDeviceOwner()
        val info = packageManager.requireInstalled(packageName, includeHidden = isDeviceOwner)
        return toManagedApplication(info, includeIcon = true, isDeviceOwner = isDeviceOwner)
            ?: throw MdmException(
                ErrorCodes.PACKAGE_NOT_FOUND,
                "$packageName has no application information",
            )
    }

    /** Suspends [packageName] and records it as blocked. */
    fun blockApplication(packageName: String) {
        suspensionManager.suspendApplication(packageName)
        policyStore.markBlocked(packageName)
    }

    /**
     * Records [packageName] as allowed and unsuspends it, unless an active
     * time restriction currently requires it to stay suspended. In that
     * case only the blocklist entry is lifted and the schedule keeps
     * control; the caller sees the real (still suspended) state.
     */
    suspend fun allowApplication(packageName: String) {
        MdmPackageNameValidator.require(packageName)
        adminManager.requireDeviceOwner()
        packageManager.requireInstalled(packageName)
        if (!isTimeRestrictedNow(packageName)) {
            suspensionManager.unsuspendApplication(packageName)
        }
        policyStore.markAllowed(packageName)
    }

    fun isApplicationSuspended(packageName: String): Boolean =
        suspensionManager.getApplicationSuspensionStatus(packageName)

    /**
     * Hides or unhides a package with
     * `DevicePolicyManager.setApplicationHidden()`. A hidden package stays
     * installed but is invisible and unusable; this is not suspension.
     */
    fun setApplicationHidden(packageName: String, hidden: Boolean) {
        MdmPackageNameValidator.require(packageName)
        val devicePolicyManager = adminManager.requireDeviceOwner()
        packageManager.requireInstalled(packageName, includeHidden = true)
        if (hidden && packageName == packageManager.ownPackageName) {
            throw MdmException(
                ErrorCodes.INVALID_ARGUMENT,
                "The device management application cannot hide itself",
            )
        }
        val admin = adminManager.adminComponent
        if (devicePolicyManager.isApplicationHidden(admin, packageName) == hidden) return
        val applied = devicePolicyManager.setApplicationHidden(admin, packageName, hidden)
        if (!applied || devicePolicyManager.isApplicationHidden(admin, packageName) != hidden) {
            throw MdmException(
                ErrorCodes.OPERATION_FAILED,
                "Android refused to ${if (hidden) "hide" else "unhide"} $packageName. " +
                    "Some system packages cannot be hidden.",
            )
        }
    }

    private fun toManagedApplication(
        info: PackageInfo,
        includeIcon: Boolean,
        isDeviceOwner: Boolean,
    ): ManagedApplication? {
        val applicationInfo = info.applicationInfo ?: return null
        val packageName = info.packageName
        val devicePolicyManager = if (isDeviceOwner) adminManager.requireDeviceOwner() else null
        val admin = adminManager.adminComponent
        return ManagedApplication(
            packageName = packageName,
            applicationName = packageManager.loadLabel(applicationInfo),
            versionName = info.versionName,
            versionCode = packageManager.readVersionCode(info),
            isSystemApplication = packageManager.isSystemApplication(applicationInfo),
            isEnabled = applicationInfo.enabled,
            isSuspended = packageManager.isSuspended(applicationInfo),
            // Only the owner can query these; without ownership nothing
            // could have set them through this app.
            isHidden = devicePolicyManager?.isApplicationHidden(admin, packageName) ?: false,
            isUninstallBlocked = devicePolicyManager?.isUninstallBlocked(admin, packageName)
                ?: false,
            installerPackageName = packageManager.getInstallerPackageName(packageName),
            policyStatus = policyStore.statusOf(packageName),
            iconPng = if (includeIcon) packageManager.loadIconPng(info) else null,
        )
    }
}
