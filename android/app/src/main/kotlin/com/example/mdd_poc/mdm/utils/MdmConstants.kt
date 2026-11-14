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

        // Application management
        const val GET_INSTALLED_APPLICATIONS = "getInstalledApplications"
        const val GET_APPLICATION_DETAILS = "getApplicationDetails"
        const val SUSPEND_APPLICATION = "suspendApplication"
        const val UNSUSPEND_APPLICATION = "unsuspendApplication"
        const val IS_APPLICATION_SUSPENDED = "isApplicationSuspended"
        const val SET_APPLICATION_HIDDEN = "setApplicationHidden"
        const val SET_APPLICATION_UNHIDDEN = "setApplicationUnhidden"

        const val SET_APPLICATION_UNINSTALL_BLOCKED = "setApplicationUninstallBlocked"

        // Installation management
        const val SET_APPLICATION_INSTALLATION_RESTRICTION = "setApplicationInstallationRestriction"
        const val SET_UNKNOWN_SOURCES_RESTRICTION = "setUnknownSourcesRestriction"
        const val GET_INSTALLATION_RESTRICTION_STATUS = "getInstallationRestrictionStatus"

        // Device security
        const val LOCK_DEVICE = "lockDevice"
        const val WIPE_DEVICE = "wipeDevice"

        // Scheduling
        const val SAVE_APPLICATION_SCHEDULE = "saveApplicationSchedule"
        const val UPDATE_APPLICATION_SCHEDULE = "updateApplicationSchedule"
        const val REMOVE_APPLICATION_SCHEDULE = "removeApplicationSchedule"
        const val GET_APPLICATION_SCHEDULES = "getApplicationSchedules"
        const val ENABLE_APPLICATION_SCHEDULE = "enableApplicationSchedule"
        const val DISABLE_APPLICATION_SCHEDULE = "disableApplicationSchedule"
        const val SYNCHRONIZE_APPLICATION_SCHEDULES = "synchronizeApplicationSchedules"

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
        const val PACKAGE_NOT_SUSPENDABLE = "PACKAGE_NOT_SUSPENDABLE"
        const val SCHEDULE_NOT_FOUND = "SCHEDULE_NOT_FOUND"
        const val FACTORY_RESET_NOT_PERFORMED = "FACTORY_RESET_NOT_PERFORMED"
        const val UNSUPPORTED_ANDROID_VERSION = "UNSUPPORTED_ANDROID_VERSION"
        const val SECURITY_EXCEPTION = "SECURITY_EXCEPTION"
        const val OPERATION_FAILED = "OPERATION_FAILED"
    }
}
