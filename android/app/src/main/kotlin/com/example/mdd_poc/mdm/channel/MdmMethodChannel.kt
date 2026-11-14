package com.example.mdd_poc.mdm.channel

import android.content.Context
import android.util.Log
import com.example.mdd_poc.mdm.MdmServiceRegistry
import com.example.mdd_poc.mdm.utils.MdmConstants
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Owns the `com.company.mdm/device_management` channel and connects it to
 * the shared native MDM services.
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

            val registry = MdmServiceRegistry.get(appContext)
            val handler = MdmMethodHandler(
                adminManager = registry.adminManager,
                provisioningManager = registry.provisioningManager,
                deviceInformationManager = registry.deviceInformationManager,
                deviceManager = registry.deviceManager,
                applicationManager = registry.applicationManager,
                scheduleManager = registry.scheduleManager,
                installationManager = registry.installationManager,
                securityManager = registry.securityManager,
                logger = registry.logger,
                scope = scope,
            )

            // Opening the app is another chance to recover a transition
            // that was missed while the process was not running.
            registry.applicationScope.launch {
                try {
                    registry.scheduleManager.synchronize("app-start")
                } catch (error: CancellationException) {
                    throw error
                } catch (error: Exception) {
                    Log.e(MdmConstants.LOG_TAG, "Schedule synchronization failed (app-start)", error)
                }
            }

            val channel = MethodChannel(messenger, MdmConstants.CHANNEL_NAME)
            channel.setMethodCallHandler(handler)
            return MdmMethodChannel(channel, scope)
        }
    }
}
