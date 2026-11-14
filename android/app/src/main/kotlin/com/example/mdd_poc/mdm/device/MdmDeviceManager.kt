package com.example.mdd_poc.mdm.device

import android.app.AlarmManager
import android.app.KeyguardManager
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.utils.AndroidVersionUtils

/**
 * Reports what the native layer is able to do on this device right now:
 * capabilities (privileges + Android version) and permission state.
 */
class MdmDeviceManager(
    private val context: Context,
    private val adminManager: MdmAdminManager,
) {

    fun getNativeCapabilities(implementedMethods: Collection<String>): Map<String, Any?> {
        val isDeviceOwner = adminManager.isDeviceOwner()
        val isAdminActive = adminManager.isDeviceAdminActive()
        return mapOf(
            "sdkInt" to AndroidVersionUtils.sdkInt,
            "implementedMethods" to implementedMethods.sorted(),
            "capabilities" to mapOf(
                "deviceAdminSupported" to adminManager.isDeviceAdminSupported(),
                "deviceAdminActive" to isAdminActive,
                "deviceOwner" to isDeviceOwner,
                "applicationSuspension" to isDeviceOwner,
                "applicationHiding" to isDeviceOwner,
                "uninstallBlocking" to isDeviceOwner,
                "installationRestriction" to isDeviceOwner,
                "unknownSourcesGlobalRestriction" to
                    (isDeviceOwner && AndroidVersionUtils.hasGlobalUnknownSourcesRestriction),
                "deviceLock" to isAdminActive,
                "deviceWipe" to isDeviceOwner,
                "lockScreenSecured" to
                    (context.getSystemService(KeyguardManager::class.java)?.isDeviceSecure ?: false),
                "exactAlarms" to canScheduleExactAlarms(),
            ),
        )
    }

    /** Every permission declared in the manifest with its granted state. */
    fun checkNativePermissions(): Map<String, Any?> {
        val info = readOwnPackageInfoWithPermissions()
        val names = info.requestedPermissions.orEmpty()
        val flags = info.requestedPermissionsFlags ?: IntArray(0)
        val permissions = names.mapIndexed { index, name ->
            val granted = index < flags.size &&
                (flags[index] and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0
            mapOf("name" to name, "granted" to granted)
        }
        return mapOf(
            "permissions" to permissions,
            "canScheduleExactAlarms" to canScheduleExactAlarms(),
        )
    }

    /** Before Android 12 exact alarms need no special access. */
    private fun canScheduleExactAlarms(): Boolean {
        if (!AndroidVersionUtils.hasExactAlarmSpecialAccess) return true
        return context.getSystemService(AlarmManager::class.java)
            ?.canScheduleExactAlarms() ?: false
    }

    private fun readOwnPackageInfoWithPermissions(): PackageInfo {
        val packageManager = context.packageManager
        return if (AndroidVersionUtils.hasPackageInfoFlags) {
            packageManager.getPackageInfo(
                context.packageName,
                PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()),
            )
        } else {
            // The flags-object overload only exists from API 33.
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(context.packageName, PackageManager.GET_PERMISSIONS)
        }
    }
}
