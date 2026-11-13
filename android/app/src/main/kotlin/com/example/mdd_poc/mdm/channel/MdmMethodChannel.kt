package com.example.mdd_poc.mdm.channel

import android.content.Context
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.admin.MdmProvisioningManager
import com.example.mdd_poc.mdm.admin.MdmProvisioningStateStore
import com.example.mdd_poc.mdm.device.MdmDeviceInformationManager
import com.example.mdd_poc.mdm.device.MdmDeviceManager
import com.example.mdd_poc.mdm.utils.MdmConstants
import com.example.mdd_poc.mdm.utils.MdmLogger
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

/**
 * Owns the `com.company.mdm/device_management` channel and is the
 * composition root of the native MDM services.
 */
class MdmMethodChannel private constructor(
    private val channel: MethodChannel,
    private val scope: CoroutineScope,
) {

    /** Detaches the handler and cancels in-flight operations. */
    fun dispose() {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    companion object {
        fun register(context: Context, messenger: BinaryMessenger): MdmMethodChannel {
            val appContext = context.applicationContext
            // Replies must be delivered on the main thread.
            val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

            val adminManager = MdmAdminManager(appContext)
            val handler = MdmMethodHandler(
                adminManager = adminManager,
                provisioningManager = MdmProvisioningManager(
                    adminManager = adminManager,
                    stateStore = MdmProvisioningStateStore(appContext),
                ),
                deviceInformationManager = MdmDeviceInformationManager(appContext, adminManager),
                deviceManager = MdmDeviceManager(appContext, adminManager),
                logger = MdmLogger.shared,
                scope = scope,
            )

            val channel = MethodChannel(messenger, MdmConstants.CHANNEL_NAME)
            channel.setMethodCallHandler(handler)
            return MdmMethodChannel(channel, scope)
        }
    }
}
