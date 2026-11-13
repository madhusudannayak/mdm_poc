package com.example.mdd_poc.mdm.models

enum class ProvisioningState {
    NOT_PROVISIONED,

    /** Active Device Administrator only; NOT Device Owner. */
    DEVICE_ADMIN_ACTIVE,
    DEVICE_OWNER_ACTIVE,
    PROVISIONING_FAILED,
}

data class ProvisioningStatus(
    val state: ProvisioningState,
    val isDeviceOwner: Boolean,
    val isProfileOwner: Boolean,
    val isDeviceAdminActive: Boolean,
    val isDeviceAdminSupported: Boolean,
    val adminComponent: String,
    val adbProvisioningCommand: String,
    val failureReason: String?,
    val lastAdminEvent: String?,
    val lastAdminEventAt: Long?,
    val provisioningCompletedAt: Long?,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "status" to state.name,
        "isDeviceOwner" to isDeviceOwner,
        "isProfileOwner" to isProfileOwner,
        "isDeviceAdminActive" to isDeviceAdminActive,
        "isDeviceAdminSupported" to isDeviceAdminSupported,
        "adminComponent" to adminComponent,
        "adbProvisioningCommand" to adbProvisioningCommand,
        "failureReason" to failureReason,
        "lastAdminEvent" to lastAdminEvent,
        "lastAdminEventAt" to lastAdminEventAt,
        "provisioningCompletedAt" to provisioningCompletedAt,
    )
}
