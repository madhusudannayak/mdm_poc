package com.example.mdd_poc.mdm.admin

import com.example.mdd_poc.mdm.models.ProvisioningState
import com.example.mdd_poc.mdm.models.ProvisioningStatus

/**
 * Resolves the provisioning state of this app from the real
 * `DevicePolicyManager` answers plus the recorded receiver history.
 *
 * It is read-only. Device Owner can only be granted from outside the app
 * (setup wizard, QR provisioning or `adb shell dpm set-device-owner`).
 */
class MdmProvisioningManager(
    private val adminManager: MdmAdminManager,
    private val stateStore: MdmProvisioningStateStore,
) {

    fun getProvisioningStatus(): ProvisioningStatus {
        val isDeviceOwner = adminManager.isDeviceOwner()
        val isProfileOwner = adminManager.isProfileOwner()
        val isAdminActive = adminManager.isDeviceAdminActive()
        val isSupported = adminManager.isDeviceAdminSupported()
        val provisioningCompletedAt = stateStore.provisioningCompletedAt
        val resolution = resolve(
            isDeviceAdminSupported = isSupported,
            isDeviceOwner = isDeviceOwner,
            isProfileOwner = isProfileOwner,
            isDeviceAdminActive = isAdminActive,
            provisioningCompletionRecorded = provisioningCompletedAt != null,
        )
        val component = adminManager.adminComponent.flattenToShortString()
        return ProvisioningStatus(
            state = resolution.state,
            isDeviceOwner = isDeviceOwner,
            isProfileOwner = isProfileOwner,
            isDeviceAdminActive = isAdminActive,
            isDeviceAdminSupported = isSupported,
            adminComponent = component,
            adbProvisioningCommand = "adb shell dpm set-device-owner $component",
            failureReason = resolution.failureReason,
            lastAdminEvent = stateStore.lastAdminEvent,
            lastAdminEventAt = stateStore.lastAdminEventAt,
            provisioningCompletedAt = provisioningCompletedAt,
        )
    }

    data class Resolution(val state: ProvisioningState, val failureReason: String? = null)

    companion object {
        /**
         * Pure state resolution, in priority order:
         *
         * 1. No device-admin support -> `PROVISIONING_FAILED`.
         * 2. Device Owner -> `DEVICE_OWNER_ACTIVE`.
         * 3. Managed provisioning completed but the app is not Device Owner
         *    (it became Profile Owner, or ownership was removed) ->
         *    `PROVISIONING_FAILED`.
         * 4. Active admin only -> `DEVICE_ADMIN_ACTIVE` (never reported as
         *    Device Owner).
         * 5. Otherwise -> `NOT_PROVISIONED`.
         */
        fun resolve(
            isDeviceAdminSupported: Boolean,
            isDeviceOwner: Boolean,
            isProfileOwner: Boolean,
            isDeviceAdminActive: Boolean,
            provisioningCompletionRecorded: Boolean,
        ): Resolution = when {
            !isDeviceAdminSupported -> Resolution(
                ProvisioningState.PROVISIONING_FAILED,
                "This device does not support device administration " +
                    "(android.software.device_admin is missing).",
            )
            isDeviceOwner -> Resolution(ProvisioningState.DEVICE_OWNER_ACTIVE)
            isProfileOwner -> Resolution(
                ProvisioningState.PROVISIONING_FAILED,
                "The app was provisioned as Profile Owner, not Device Owner. " +
                    "Fully managed mode requires Device Owner provisioning on a " +
                    "factory-reset device.",
            )
            provisioningCompletionRecorded -> Resolution(
                ProvisioningState.PROVISIONING_FAILED,
                "Managed provisioning completed on this device, but the app does " +
                    "not hold Device Owner. Factory reset the device and provision again.",
            )
            isDeviceAdminActive -> Resolution(ProvisioningState.DEVICE_ADMIN_ACTIVE)
            else -> Resolution(ProvisioningState.NOT_PROVISIONED)
        }
    }
}
