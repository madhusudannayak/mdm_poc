package com.example.mdd_poc.mdm.device

import android.app.KeyguardManager
import android.app.admin.DeviceAdminInfo
import android.content.Context
import android.os.Build
import android.util.Log
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.AndroidVersionUtils
import com.example.mdd_poc.mdm.utils.MdmConstants
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes
import com.example.mdd_poc.mdm.utils.MdmLogger

/** Device lock and factory reset. */
class MdmSecurityManager(
    context: Context,
    private val adminManager: MdmAdminManager,
    private val logger: MdmLogger,
) {
    private val keyguardManager: KeyguardManager? =
        context.getSystemService(KeyguardManager::class.java)

    /** True when a PIN, pattern or password protects the lock screen. */
    fun isLockScreenSecured(): Boolean = keyguardManager?.isDeviceSecure ?: false

    /**
     * Locks the device now with `DevicePolicyManager.lockNow()`.
     *
     * Needs an active admin that was granted the `force-lock` policy
     * (declared in `res/xml/mdm_device_admin.xml`). Without a screen lock
     * configured, Android only turns the screen off.
     */
    fun lockDevice() {
        val devicePolicyManager = adminManager.requireActiveAdmin()
        val admin = adminManager.adminComponent
        if (!devicePolicyManager.hasGrantedPolicy(admin, DeviceAdminInfo.USES_POLICY_FORCE_LOCK)) {
            throw MdmException(
                ErrorCodes.DEVICE_ADMIN_REQUIRED,
                "The device administrator was not granted the force-lock policy",
            )
        }
        devicePolicyManager.lockNow()
    }

    /**
     * Factory resets the device. Terminal: Android may start wiping before
     * this call returns, so the caller may never receive a reply.
     *
     * [confirmed] must be true and must come from an explicit user
     * confirmation. An audit event is recorded before the wipe starts.
     */
    fun wipeDevice(confirmed: Boolean) {
        if (!confirmed) {
            throw MdmException(
                ErrorCodes.INVALID_ARGUMENT,
                "Factory reset requires explicit confirmation",
            )
        }
        val devicePolicyManager = adminManager.requireDeviceOwner()
        Log.w(MdmConstants.LOG_TAG, "AUDIT: factory reset confirmed; wiping device")
        logger.record(
            operationName = AUDIT_FACTORY_RESET_INITIATED,
            requestTimestamp = System.currentTimeMillis(),
            success = true,
        )
        if (AndroidVersionUtils.isAtLeast(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)) {
            // Android 14+: wipeData() no longer resets the whole device for
            // apps targeting it; wipeDevice() is the Device Owner API.
            devicePolicyManager.wipeDevice(0)
        } else {
            devicePolicyManager.wipeData(0)
        }
    }

    companion object {
        const val AUDIT_FACTORY_RESET_INITIATED = "audit.factoryResetInitiated"
    }
}
