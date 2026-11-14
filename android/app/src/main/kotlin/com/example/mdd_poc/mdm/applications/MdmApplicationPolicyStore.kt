package com.example.mdd_poc.mdm.applications

import android.content.Context
import com.example.mdd_poc.mdm.models.ApplicationPolicyStatus

/**
 * Persists the organization's application blocklist and allowlist.
 *
 * A package is in at most one list. The lists record intent; the real
 * device state (suspended or not) is always read from Android separately.
 */
class MdmApplicationPolicyStore(context: Context) {
    private val preferences =
        context.applicationContext.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    val blockedPackages: Set<String> get() = read(KEY_BLOCKED)

    val allowedPackages: Set<String> get() = read(KEY_ALLOWED)

    fun statusOf(packageName: String): ApplicationPolicyStatus = when (packageName) {
        in blockedPackages -> ApplicationPolicyStatus.BLOCKED
        in allowedPackages -> ApplicationPolicyStatus.ALLOWED
        else -> ApplicationPolicyStatus.UNSPECIFIED
    }

    fun markBlocked(packageName: String) = synchronized(this) {
        write(blocked = blockedPackages + packageName, allowed = allowedPackages - packageName)
    }

    fun markAllowed(packageName: String) = synchronized(this) {
        write(blocked = blockedPackages - packageName, allowed = allowedPackages + packageName)
    }

    private fun read(key: String): Set<String> =
        // The returned set must not be modified, so hand out a copy.
        preferences.getStringSet(key, emptySet()).orEmpty().toSet()

    private fun write(blocked: Set<String>, allowed: Set<String>) {
        preferences.edit()
            .putStringSet(KEY_BLOCKED, blocked)
            .putStringSet(KEY_ALLOWED, allowed)
            .apply()
    }

    private companion object {
        const val FILE_NAME = "mdm_application_policy"
        const val KEY_BLOCKED = "blocked_packages"
        const val KEY_ALLOWED = "allowed_packages"
    }
}
