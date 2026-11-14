package com.example.mdd_poc.mdm.models

/** Organizational decision recorded for a package. */
enum class ApplicationPolicyStatus {
    /** On the blocklist: explicitly prohibited. Enforced by suspension. */
    BLOCKED,

    /** On the allowlist: explicitly permitted. */
    ALLOWED,

    /** No organizational decision recorded. */
    UNSPECIFIED,
}

/**
 * An installed application with its real Android state.
 *
 * Suspended, hidden, disabled and uninstalled are different states:
 *  - [isSuspended]: installed and visible, but cannot be launched.
 *  - [isHidden]: installed, but invisible and unavailable to the user.
 *  - [isEnabled] false: the package is disabled.
 */
data class ManagedApplication(
    val packageName: String,
    val applicationName: String,
    val versionName: String?,
    val versionCode: Long?,
    val isSystemApplication: Boolean,
    val isEnabled: Boolean,
    val isSuspended: Boolean,
    val isHidden: Boolean,
    val isUninstallBlocked: Boolean,
    val installerPackageName: String?,
    val policyStatus: ApplicationPolicyStatus,
    val iconPng: ByteArray?,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "packageName" to packageName,
        "applicationName" to applicationName,
        "versionName" to versionName,
        "versionCode" to versionCode,
        "isSystemApplication" to isSystemApplication,
        "isEnabled" to isEnabled,
        "isSuspended" to isSuspended,
        "isHidden" to isHidden,
        "isUninstallBlocked" to isUninstallBlocked,
        "installerPackageName" to installerPackageName,
        "policyStatus" to policyStatus.name,
        "iconPng" to iconPng,
    )
}
