package com.example.mdd_poc.mdm.admin

import android.content.Context

/**
 * Persists DeviceAdminReceiver lifecycle events so provisioning history
 * survives process death. Holds timestamps and event names only.
 */
class MdmProvisioningStateStore(context: Context) {
    private val preferences =
        context.applicationContext.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    val lastAdminEvent: String? get() = preferences.getString(KEY_LAST_EVENT, null)

    val lastAdminEventAt: Long? get() = readTimestamp(KEY_LAST_EVENT_AT)

    val provisioningCompletedAt: Long? get() = readTimestamp(KEY_PROVISIONING_COMPLETED_AT)

    fun recordAdminEvent(event: String, timestamp: Long = System.currentTimeMillis()) {
        preferences.edit()
            .putString(KEY_LAST_EVENT, event)
            .putLong(KEY_LAST_EVENT_AT, timestamp)
            .apply()
    }

    fun recordProvisioningComplete(timestamp: Long = System.currentTimeMillis()) {
        preferences.edit()
            .putString(KEY_LAST_EVENT, EVENT_PROVISIONING_COMPLETE)
            .putLong(KEY_LAST_EVENT_AT, timestamp)
            .putLong(KEY_PROVISIONING_COMPLETED_AT, timestamp)
            .apply()
    }

    private fun readTimestamp(key: String): Long? =
        if (preferences.contains(key)) preferences.getLong(key, 0L) else null

    companion object {
        const val EVENT_ADMIN_ENABLED = "ADMIN_ENABLED"
        const val EVENT_ADMIN_DISABLE_REQUESTED = "ADMIN_DISABLE_REQUESTED"
        const val EVENT_ADMIN_DISABLED = "ADMIN_DISABLED"
        const val EVENT_PROVISIONING_COMPLETE = "PROVISIONING_COMPLETE"

        private const val FILE_NAME = "mdm_provisioning_state"
        private const val KEY_LAST_EVENT = "last_admin_event"
        private const val KEY_LAST_EVENT_AT = "last_admin_event_at"
        private const val KEY_PROVISIONING_COMPLETED_AT = "provisioning_completed_at"
    }
}
