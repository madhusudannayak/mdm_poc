package com.example.mdd_poc.mdm.scheduling

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.mdd_poc.mdm.MdmServiceRegistry

/**
 * Deferrable safety net: periodically reconciles application state in case
 * a transition alarm was delayed or lost. It is not the timing mechanism.
 */
class MdmScheduleSyncWorker(
    context: Context,
    parameters: WorkerParameters,
) : CoroutineWorker(context, parameters) {

    override suspend fun doWork(): Result {
        MdmServiceRegistry.get(applicationContext).scheduleManager.synchronize("periodic")
        return Result.success()
    }
}
