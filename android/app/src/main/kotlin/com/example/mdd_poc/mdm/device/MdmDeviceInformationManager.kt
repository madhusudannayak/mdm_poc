package com.example.mdd_poc.mdm.device

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.models.AndroidVersion
import com.example.mdd_poc.mdm.models.DeviceInformation
import com.example.mdd_poc.mdm.utils.AndroidVersionUtils
import com.example.mdd_poc.mdm.utils.MdmConstants

/**
 * Reads device details from Android framework APIs. Values Android cannot
 * provide are returned as null and shown as "Unavailable"; nothing is
 * substituted or hardcoded.
 */
class MdmDeviceInformationManager(
    private val context: Context,
    private val adminManager: MdmAdminManager,
) {

    fun getDeviceInformation(): DeviceInformation {
        val packageInfo = readOwnPackageInfo()
        return DeviceInformation(
            manufacturer = Build.MANUFACTURER,
            model = Build.MODEL,
            brand = Build.BRAND,
            deviceName = readDeviceName(),
            androidVersion = Build.VERSION.RELEASE,
            sdkVersion = Build.VERSION.SDK_INT,
            securityPatchLevel = readSecurityPatch(),
            buildFingerprint = Build.FINGERPRINT,
            appVersionName = packageInfo?.versionName,
            appVersionCode = packageInfo?.let(::readVersionCode),
            isDeviceOwner = adminManager.isDeviceOwner(),
            isDeviceAdminActive = adminManager.isDeviceAdminActive(),
            managementMode = adminManager.getManagementMode(),
            batteryPercentage = readBatteryPercentage(),
        )
    }

    fun getAndroidVersion(): AndroidVersion = AndroidVersion(
        release = Build.VERSION.RELEASE,
        sdkInt = Build.VERSION.SDK_INT,
        codename = Build.VERSION.CODENAME,
        securityPatch = readSecurityPatch(),
    )

    private fun readSecurityPatch(): String? =
        Build.VERSION.SECURITY_PATCH.takeIf { it.isNotBlank() }

    /** The user-visible device name from Settings, when the OS exposes it. */
    private fun readDeviceName(): String? = try {
        Settings.Global.getString(context.contentResolver, Settings.Global.DEVICE_NAME)
            ?.takeIf { it.isNotBlank() }
    } catch (error: SecurityException) {
        Log.w(MdmConstants.LOG_TAG, "Device name is not readable on this device", error)
        null
    }

    /** Battery level from the sticky ACTION_BATTERY_CHANGED broadcast. */
    private fun readBatteryPercentage(): Int? {
        val battery: Intent =
            context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                ?: return null
        val level = battery.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = battery.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        if (level < 0 || scale <= 0) return null
        return (level * 100) / scale
    }

    private fun readOwnPackageInfo(): PackageInfo? = try {
        val packageManager = context.packageManager
        if (AndroidVersionUtils.hasPackageInfoFlags) {
            packageManager.getPackageInfo(
                context.packageName,
                PackageManager.PackageInfoFlags.of(0),
            )
        } else {
            // The flags-object overload only exists from API 33.
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(context.packageName, 0)
        }
    } catch (error: PackageManager.NameNotFoundException) {
        Log.w(MdmConstants.LOG_TAG, "Own package info is unavailable", error)
        null
    }

    private fun readVersionCode(info: PackageInfo): Long =
        if (AndroidVersionUtils.hasLongVersionCode) {
            info.longVersionCode
        } else {
            // longVersionCode only exists from API 28.
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
}
