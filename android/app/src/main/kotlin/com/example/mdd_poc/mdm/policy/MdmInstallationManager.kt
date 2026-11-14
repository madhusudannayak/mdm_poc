package com.example.mdd_poc.mdm.policy

import android.os.UserManager
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.applications.MdmPackageManager
import com.example.mdd_poc.mdm.applications.MdmPackageNameValidator
import com.example.mdd_poc.mdm.models.InstallationRestrictionStatus
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes

/**
 * Installation controls for a fully managed device.
 *
 * Two different things are kept apart:
 *  - Global installation restriction (`DISALLOW_INSTALL_APPS`): nothing can
 *    be installed, from any source.
 *  - Unknown-sources restriction (`DISALLOW_INSTALL_UNKNOWN_SOURCES` and,
 *    from Android 10, `..._GLOBALLY`): only sideloading is blocked; store
 *    installations still work.
 *
 * Everything is enforced by Android itself through Device Owner APIs.
 */
class MdmInstallationManager(
    private val adminManager: MdmAdminManager,
    private val restrictionManager: MdmRestrictionManager,
    private val packageManager: MdmPackageManager,
) {

    fun setApplicationInstallationRestriction(enabled: Boolean): InstallationRestrictionStatus {
        restrictionManager.setRestriction(UserManager.DISALLOW_INSTALL_APPS, enabled)
        return getInstallationRestrictionStatus()
    }

    fun setUnknownSourcesRestriction(enabled: Boolean): InstallationRestrictionStatus {
        restrictionManager.setRestriction(UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES, enabled)
        if (restrictionManager.isSupported(UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES_GLOBALLY)) {
            restrictionManager.setRestriction(
                UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES_GLOBALLY,
                enabled,
            )
        }
        return getInstallationRestrictionStatus()
    }

    /**
     * Blocks or allows uninstalling [packageName] with
     * `DevicePolicyManager.setUninstallBlocked()`, and confirms the result.
     */
    fun setApplicationUninstallBlocked(packageName: String, blocked: Boolean) {
        MdmPackageNameValidator.require(packageName)
        val devicePolicyManager = adminManager.requireDeviceOwner()
        packageManager.requireInstalled(packageName, includeHidden = true)
        val admin = adminManager.adminComponent
        devicePolicyManager.setUninstallBlocked(admin, packageName, blocked)
        if (devicePolicyManager.isUninstallBlocked(admin, packageName) != blocked) {
            throw MdmException(
                ErrorCodes.OPERATION_FAILED,
                "Android did not ${if (blocked) "block" else "unblock"} uninstalling $packageName",
            )
        }
    }

    /** Readable without privileges; the uninstall list needs Device Owner. */
    fun getInstallationRestrictionStatus(): InstallationRestrictionStatus {
        val globalKey = UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES_GLOBALLY
        return InstallationRestrictionStatus(
            installAppsRestricted =
                restrictionManager.isEffective(UserManager.DISALLOW_INSTALL_APPS),
            unknownSourcesRestricted =
                restrictionManager.isEffective(UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES),
            unknownSourcesGloballyRestricted =
                if (restrictionManager.isSupported(globalKey)) {
                    restrictionManager.isEffective(globalKey)
                } else {
                    null
                },
            uninstallBlockedPackages = readUninstallBlockedPackages(),
        )
    }

    private fun readUninstallBlockedPackages(): List<String> {
        if (!adminManager.isDeviceOwner()) return emptyList()
        val devicePolicyManager = adminManager.requireDeviceOwner()
        val admin = adminManager.adminComponent
        return packageManager.getInstalledPackages(includeHidden = true)
            .map { it.packageName }
            .filter { devicePolicyManager.isUninstallBlocked(admin, it) }
            .sorted()
    }
}
