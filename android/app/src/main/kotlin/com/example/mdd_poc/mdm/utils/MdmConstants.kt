package com.example.mdd_poc.mdm.utils

/**
 * Channel contract constants. Must stay in sync with
 * `lib/core/constants/mdm_constants.dart`.
 */
object MdmConstants {
    const val CHANNEL_NAME = "com.company.mdm/device_management"
    const val LOG_TAG = "MdmNative"

    object Methods {
        // Device information
        const val GET_DEVICE_INFO = "getDeviceInfo"
        const val GET_ANDROID_VERSION = "getAndroidVersion"
        const val GET_DEVICE_MANAGEMENT_STATUS = "getDeviceManagementStatus"
        const val GET_DEVICE_ADMIN_STATUS = "getDeviceAdminStatus"
        const val GET_DEVICE_OWNER_STATUS = "getDeviceOwnerStatus"

        // Device provisioning
        const val IS_DEVICE_OWNER = "isDeviceOwner"
        const val IS_DEVICE_ADMIN_ACTIVE = "isDeviceAdminActive"
        const val GET_PROVISIONING_STATUS = "getProvisioningStatus"

        // System
        const val GET_NATIVE_CAPABILITIES = "getNativeCapabilities"
        const val GET_NATIVE_LOGS = "getNativeLogs"
        const val CHECK_NATIVE_PERMISSIONS = "checkNativePermissions"
    }

    object ErrorCodes {
        const val DEVICE_OWNER_REQUIRED = "DEVICE_OWNER_REQUIRED"
        const val DEVICE_ADMIN_REQUIRED = "DEVICE_ADMIN_REQUIRED"
        const val DEVICE_ADMIN_UNSUPPORTED = "DEVICE_ADMIN_UNSUPPORTED"
        const val INVALID_ARGUMENT = "INVALID_ARGUMENT"
        const val PACKAGE_NOT_FOUND = "PACKAGE_NOT_FOUND"
        const val UNSUPPORTED_ANDROID_VERSION = "UNSUPPORTED_ANDROID_VERSION"
        const val SECURITY_EXCEPTION = "SECURITY_EXCEPTION"
        const val OPERATION_FAILED = "OPERATION_FAILED"
    }
}
