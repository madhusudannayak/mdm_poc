package com.example.mdd_poc.mdm.applications

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.util.Log
import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.AndroidVersionUtils
import com.example.mdd_poc.mdm.utils.MdmConstants
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes
import java.io.ByteArrayOutputStream
import java.util.concurrent.ConcurrentHashMap

/**
 * Thin, version-aware wrapper around Android [PackageManager]. It only reads
 * package data; it never changes package state.
 *
 * Seeing every installed package requires the `QUERY_ALL_PACKAGES`
 * permission declared in the manifest (Android 11+ package visibility).
 */
class MdmPackageManager(private val context: Context) {
    private val packageManager: PackageManager get() = context.packageManager

    /** Rendered icons, keyed by package and its last update time. */
    private val iconCache = ConcurrentHashMap<String, ByteArray>()

    val ownPackageName: String get() = context.packageName

    /**
     * Installed packages for the current user.
     *
     * With [includeHidden], packages hidden by the device owner are returned
     * too; packages that were uninstalled but kept their data are filtered
     * out, because they are not installed.
     */
    fun getInstalledPackages(includeHidden: Boolean): List<PackageInfo> {
        val flags = if (includeHidden) PackageManager.MATCH_UNINSTALLED_PACKAGES else 0
        val packages = if (AndroidVersionUtils.hasPackageInfoFlags) {
            packageManager.getInstalledPackages(PackageManager.PackageInfoFlags.of(flags.toLong()))
        } else {
            // The flags-object overload only exists from API 33.
            @Suppress("DEPRECATION")
            packageManager.getInstalledPackages(flags)
        }
        return packages.filter(::isInstalled)
    }

    /** Package info, or null when the package is not installed for this user. */
    fun getPackageInfoOrNull(packageName: String, includeHidden: Boolean): PackageInfo? {
        val flags = if (includeHidden) PackageManager.MATCH_UNINSTALLED_PACKAGES else 0
        return try {
            val info = if (AndroidVersionUtils.hasPackageInfoFlags) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(flags.toLong()),
                )
            } else {
                // The flags-object overload only exists from API 33.
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, flags)
            }
            info.takeIf(::isInstalled)
        } catch (_: PackageManager.NameNotFoundException) {
            // "Not installed" is an expected answer here, reported as null.
            null
        }
    }

    /** Package info, or `PACKAGE_NOT_FOUND`. */
    fun requireInstalled(packageName: String, includeHidden: Boolean = true): PackageInfo =
        getPackageInfoOrNull(packageName, includeHidden)
            ?: throw MdmException(
                ErrorCodes.PACKAGE_NOT_FOUND,
                "$packageName is not installed on this device",
            )

    fun loadLabel(info: ApplicationInfo): String =
        packageManager.getApplicationLabel(info).toString()

    fun isSystemApplication(info: ApplicationInfo): Boolean =
        (info.flags and ApplicationInfo.FLAG_SYSTEM) != 0

    /** Suspended state as recorded by Android on the package itself. */
    fun isSuspended(info: ApplicationInfo): Boolean =
        (info.flags and ApplicationInfo.FLAG_SUSPENDED) != 0

    fun readVersionCode(info: PackageInfo): Long =
        if (AndroidVersionUtils.hasLongVersionCode) {
            info.longVersionCode
        } else {
            // longVersionCode only exists from API 28.
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }

    /** The package that installed [packageName], when Android discloses it. */
    fun getInstallerPackageName(packageName: String): String? = try {
        if (AndroidVersionUtils.hasInstallSourceInfo) {
            packageManager.getInstallSourceInfo(packageName).installingPackageName
        } else {
            // getInstallSourceInfo only exists from API 30.
            @Suppress("DEPRECATION")
            packageManager.getInstallerPackageName(packageName)
        }
    } catch (_: PackageManager.NameNotFoundException) {
        null
    } catch (_: IllegalArgumentException) {
        // Thrown by the pre-30 API for unknown packages.
        null
    }

    /**
     * Application icon as a small PNG, or null when it cannot be rendered.
     * Rendering is slow, so results are cached until the package changes.
     */
    fun loadIconPng(info: PackageInfo): ByteArray? {
        val applicationInfo = info.applicationInfo ?: return null
        val cacheKey = "${info.packageName}:${info.lastUpdateTime}"
        iconCache[cacheKey]?.let { return it }
        return renderIconPng(applicationInfo)?.also { iconCache[cacheKey] = it }
    }

    private fun renderIconPng(info: ApplicationInfo): ByteArray? = try {
        val drawable = packageManager.getApplicationIcon(info)
        val bitmap = Bitmap.createBitmap(ICON_SIZE_PX, ICON_SIZE_PX, Bitmap.Config.ARGB_8888)
        try {
            drawable.setBounds(0, 0, ICON_SIZE_PX, ICON_SIZE_PX)
            drawable.draw(Canvas(bitmap))
            ByteArrayOutputStream().use { stream ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            }
        } finally {
            bitmap.recycle()
        }
    } catch (error: RuntimeException) {
        Log.w(MdmConstants.LOG_TAG, "Icon unavailable for ${info.packageName}", error)
        null
    }

    private fun isInstalled(info: PackageInfo): Boolean {
        val flags = info.applicationInfo?.flags ?: return false
        return (flags and ApplicationInfo.FLAG_INSTALLED) != 0
    }

    private companion object {
        const val ICON_SIZE_PX = 96
    }
}
