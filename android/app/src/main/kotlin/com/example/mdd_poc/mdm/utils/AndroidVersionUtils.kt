package com.example.mdd_poc.mdm.utils

import android.os.Build

/** Central place for API-level checks so version gates are easy to audit. */
object AndroidVersionUtils {
    val sdkInt: Int get() = Build.VERSION.SDK_INT

    fun isAtLeast(apiLevel: Int): Boolean = Build.VERSION.SDK_INT >= apiLevel

    /** Android 9: `PackageInfo.longVersionCode`. */
    val hasLongVersionCode: Boolean get() = isAtLeast(Build.VERSION_CODES.P)

    /** Android 10: `DISALLOW_INSTALL_UNKNOWN_SOURCES_GLOBALLY`. */
    val hasGlobalUnknownSourcesRestriction: Boolean get() = isAtLeast(Build.VERSION_CODES.Q)

    /** Android 12: exact alarms became a revocable special access. */
    val hasExactAlarmSpecialAccess: Boolean get() = isAtLeast(Build.VERSION_CODES.S)

    /** Android 13: `PackageManager.PackageInfoFlags`. */
    val hasPackageInfoFlags: Boolean get() = isAtLeast(Build.VERSION_CODES.TIRAMISU)
}
