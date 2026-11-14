package com.example.mdd_poc.mdm.policy

import android.content.Context
import android.os.UserManager
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.AndroidVersionUtils
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes

/**
 * Applies and reads Android user restrictions.
 *
 * Restrictions are set with `DevicePolicyManager.addUserRestriction()` and
 * always read back with `UserManager.hasUserRestriction()`, which reports
 * the EFFECTIVE state. Only restrictions on the allowlist below can be
 * changed through this class.
 */
class MdmRestrictionManager(
    context: Context,
    private val adminManager: MdmAdminManager,
) {
    private val userManager: UserManager? = context.getSystemService(UserManager::class.java)

    /** True when [restriction] is currently enforced, whoever set it. */
    fun isEffective(restriction: String): Boolean =
        userManager?.hasUserRestriction(restriction) ?: false

    fun isSupported(restriction: String): Boolean = when (restriction) {
        UserManager.DISALLOW_INSTALL_APPS,
        UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES -> true
        UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES_GLOBALLY ->
            AndroidVersionUtils.hasGlobalUnknownSourcesRestriction
        else -> false
    }

    /**
     * Idempotently adds or clears [restriction] as Device Owner, then
     * confirms the effective state. Throws when Android did not end up in
     * the requested state.
     */
    fun setRestriction(restriction: String, enabled: Boolean) {
        if (!isSupported(restriction)) {
            throw MdmException(
                ErrorCodes.UNSUPPORTED_ANDROID_VERSION,
                "Restriction \"$restriction\" is not supported on Android API " +
                    "${AndroidVersionUtils.sdkInt}",
            )
        }
        val devicePolicyManager = adminManager.requireDeviceOwner()
        val admin = adminManager.adminComponent
        if (enabled) {
            devicePolicyManager.addUserRestriction(admin, restriction)
        } else {
            devicePolicyManager.clearUserRestriction(admin, restriction)
        }
        if (isEffective(restriction) != enabled) {
            throw MdmException(
                ErrorCodes.OPERATION_FAILED,
                if (enabled) {
                    "Android did not apply the \"$restriction\" restriction"
                } else {
                    "\"$restriction\" is still enforced by another policy source"
                },
            )
        }
    }
}
