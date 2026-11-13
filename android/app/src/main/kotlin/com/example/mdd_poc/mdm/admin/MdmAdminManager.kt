package com.example.mdd_poc.mdm.admin

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import com.example.mdd_poc.mdm.models.ManagementMode
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes

/**
 * Single source of truth for this app's management privileges. Every
 * answer comes straight from [DevicePolicyManager]; nothing is cached or
 * inferred, so the result always reflects the device's real state.
 */
class MdmAdminManager(private val context: Context) {

    /** Component of [MdmDeviceAdminReceiver], used for all admin API calls. */
    val adminComponent: ComponentName =
        ComponentName(context, MdmDeviceAdminReceiver::class.java)

    private val devicePolicyManager: DevicePolicyManager? =
        context.getSystemService(DevicePolicyManager::class.java)

    val packageName: String get() = context.packageName

    /** False on devices without `android.software.device_admin`. */
    fun isDeviceAdminSupported(): Boolean =
        devicePolicyManager != null &&
            context.packageManager.hasSystemFeature(PackageManager.FEATURE_DEVICE_ADMIN)

    /** True when the receiver is an active Device Administrator. */
    fun isDeviceAdminActive(): Boolean =
        devicePolicyManager?.isAdminActive(adminComponent) ?: false

    /**
     * True only when this app is the Device Owner. An active Device
     * Administrator is not sufficient.
     */
    fun isDeviceOwner(): Boolean =
        devicePolicyManager?.isDeviceOwnerApp(context.packageName) ?: false

    fun isProfileOwner(): Boolean =
        devicePolicyManager?.isProfileOwnerApp(context.packageName) ?: false

    fun getManagementMode(): ManagementMode = when {
        isDeviceOwner() -> ManagementMode.FULLY_MANAGED
        isProfileOwner() -> ManagementMode.PROFILE_OWNER
        isDeviceAdminActive() -> ManagementMode.DEVICE_ADMIN
        else -> ManagementMode.UNMANAGED
    }

    /**
     * Returns the [DevicePolicyManager] for a Device Owner operation, or
     * throws [MdmException] with `DEVICE_OWNER_REQUIRED`.
     */
    fun requireDeviceOwner(): DevicePolicyManager {
        val manager = requireDevicePolicyManager()
        if (!manager.isDeviceOwnerApp(context.packageName)) {
            throw MdmException(
                ErrorCodes.DEVICE_OWNER_REQUIRED,
                "Device Owner privileges required",
            )
        }
        return manager
    }

    /**
     * Returns the [DevicePolicyManager] for an operation that needs an
     * active admin, or throws [MdmException] with `DEVICE_ADMIN_REQUIRED`.
     */
    fun requireActiveAdmin(): DevicePolicyManager {
        val manager = requireDevicePolicyManager()
        if (!manager.isAdminActive(adminComponent)) {
            throw MdmException(
                ErrorCodes.DEVICE_ADMIN_REQUIRED,
                "An active device administrator is required",
            )
        }
        return manager
    }

    private fun requireDevicePolicyManager(): DevicePolicyManager =
        devicePolicyManager?.takeIf { isDeviceAdminSupported() }
            ?: throw MdmException(
                ErrorCodes.DEVICE_ADMIN_UNSUPPORTED,
                "This device does not support device administration",
            )
}
