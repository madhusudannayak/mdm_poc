package com.example.mdd_poc.mdm.admin

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import com.example.mdd_poc.R
import com.example.mdd_poc.mdm.utils.MdmLogger

/**
 * The device-admin component of this app. Its component name is what is
 * provisioned as Device Owner:
 * `com.example.mdd_poc/.mdm.admin.MdmDeviceAdminReceiver`.
 *
 * The receiver only records lifecycle events. It never attempts to obtain
 * privileges: activation and Device Owner provisioning are always performed
 * from outside the app (setup wizard, QR provisioning or ADB).
 */
class MdmDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        record(context, MdmProvisioningStateStore.EVENT_ADMIN_ENABLED)
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        record(context, MdmProvisioningStateStore.EVENT_ADMIN_DISABLE_REQUESTED)
        return context.getString(R.string.mdm_admin_disable_warning)
    }

    override fun onDisabled(context: Context, intent: Intent) {
        record(context, MdmProvisioningStateStore.EVENT_ADMIN_DISABLED)
    }

    /** Called after managed provisioning (setup wizard / QR) finishes. */
    override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
        val requestedAt = System.currentTimeMillis()
        MdmProvisioningStateStore(context).recordProvisioningComplete(requestedAt)
        MdmLogger.shared.record(
            operationName = "admin.${MdmProvisioningStateStore.EVENT_PROVISIONING_COMPLETE}",
            requestTimestamp = requestedAt,
            success = true,
        )
    }

    private fun record(context: Context, event: String) {
        val requestedAt = System.currentTimeMillis()
        MdmProvisioningStateStore(context).recordAdminEvent(event, requestedAt)
        MdmLogger.shared.record(
            operationName = "admin.$event",
            requestTimestamp = requestedAt,
            success = true,
        )
    }
}
