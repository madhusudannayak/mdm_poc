package com.example.mdd_poc.mdm.models

/**
 * Effective installation restrictions, read back from Android.
 *
 * [installAppsRestricted] blocks every installation. The unknown-sources
 * flags only block sideloading and do NOT block store installations.
 */
data class InstallationRestrictionStatus(
    val installAppsRestricted: Boolean,
    val unknownSourcesRestricted: Boolean,
    /** Null below Android 10, where the global restriction does not exist. */
    val unknownSourcesGloballyRestricted: Boolean?,
    val uninstallBlockedPackages: List<String>,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "installAppsRestricted" to installAppsRestricted,
        "unknownSourcesRestricted" to unknownSourcesRestricted,
        "unknownSourcesGloballyRestricted" to unknownSourcesGloballyRestricted,
        "uninstallBlockedPackages" to uninstallBlockedPackages,
    )
}
