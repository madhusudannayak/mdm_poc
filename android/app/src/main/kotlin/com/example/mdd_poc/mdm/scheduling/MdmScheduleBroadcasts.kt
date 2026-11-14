package com.example.mdd_poc.mdm.scheduling

import android.content.BroadcastReceiver
import android.content.Context
import android.util.Log
import com.example.mdd_poc.mdm.MdmServiceRegistry
import com.example.mdd_poc.mdm.utils.MdmConstants
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch

/**
 * Runs a schedule reconciliation from a broadcast without blocking the main
 * thread, keeping the receiver alive until the pass has finished.
 */
internal fun BroadcastReceiver.synchronizeSchedules(context: Context, trigger: String) {
    val pending = goAsync()
    val registry = MdmServiceRegistry.get(context)
    registry.applicationScope.launch {
        try {
            registry.scheduleManager.synchronize(trigger)
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            // Reported, not hidden: the periodic job and the next trigger
            // will reconcile again.
            Log.e(MdmConstants.LOG_TAG, "Schedule synchronization failed ($trigger)", error)
            registry.logger.record(
                operationName = "schedule.sync[$trigger]",
                requestTimestamp = System.currentTimeMillis(),
                success = false,
                errorCode = MdmConstants.ErrorCodes.OPERATION_FAILED,
                errorMessage = error.message ?: error.javaClass.simpleName,
            )
        } finally {
            pending.finish()
        }
    }
}
