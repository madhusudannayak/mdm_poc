package com.example.mdd_poc.mdm.models

/**
 * How this app manages the device. Device Administrator, Profile Owner and
 * Device Owner are different roles and are never conflated.
 */
enum class ManagementMode {
    /** The app is Device Owner of a fully managed device. */
    FULLY_MANAGED,

    /** The app owns a profile (for example a work profile) only. */
    PROFILE_OWNER,

    /** Legacy active Device Administrator without any owner role. */
    DEVICE_ADMIN,

    UNMANAGED,
}

/** Device details. Null means Android did not provide the value. */
data class DeviceInformation(
    val manufacturer: String,
    val model: String,
    val brand: String,
    val deviceName: String?,
    val androidVersion: String,
    val sdkVersion: Int,
    val securityPatchLevel: String?,
    val buildFingerprint: String,
    val appVersionName: String?,
    val appVersionCode: Long?,
    val isDeviceOwner: Boolean,
    val isDeviceAdminActive: Boolean,
    val managementMode: ManagementMode,
    val batteryPercentage: Int?,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "manufacturer" to manufacturer,
        "model" to model,
        "brand" to brand,
        "deviceName" to deviceName,
        "androidVersion" to androidVersion,
        "sdkVersion" to sdkVersion,
        "securityPatchLevel" to securityPatchLevel,
        "buildFingerprint" to buildFingerprint,
        "appVersionName" to appVersionName,
        "appVersionCode" to appVersionCode,
        "isDeviceOwner" to isDeviceOwner,
        "isDeviceAdminActive" to isDeviceAdminActive,
        "managementMode" to managementMode.name,
        "batteryPercentage" to batteryPercentage,
    )
}

data class AndroidVersion(
    val release: String,
    val sdkInt: Int,
    val codename: String,
    val securityPatch: String?,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "release" to release,
        "sdkInt" to sdkInt,
        "codename" to codename,
        "securityPatch" to securityPatch,
    )
}
