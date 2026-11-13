package com.example.mdd_poc.mdm.utils

import android.util.Log
import com.example.mdd_poc.mdm.models.OperationLogEntry
import java.util.UUID

/**
 * Records native operations for the Native Logs screen and mirrors them to
 * Logcat. Only operation metadata is stored: never arguments, credentials or
 * personal data.
 *
 * Entries are held in a bounded in-memory buffer for the life of the
 * process. Durable (Room) storage is added with the operation-log phase.
 */
class MdmLogger(private val capacity: Int = DEFAULT_CAPACITY) {
    private val entries = ArrayDeque<OperationLogEntry>()

    fun record(
        operationName: String,
        requestTimestamp: Long,
        success: Boolean,
        packageName: String? = null,
        errorCode: String? = null,
        errorMessage: String? = null,
    ): OperationLogEntry {
        val entry = OperationLogEntry(
            operationId = UUID.randomUUID().toString(),
            operationName = operationName,
            packageName = packageName,
            requestTimestamp = requestTimestamp,
            executionTimestamp = System.currentTimeMillis(),
            success = success,
            errorCode = errorCode,
            errorMessage = errorMessage,
            sdkVersion = AndroidVersionUtils.sdkInt,
        )
        synchronized(entries) {
            entries.addFirst(entry)
            while (entries.size > capacity) entries.removeLast()
        }
        if (success) {
            Log.i(MdmConstants.LOG_TAG, "$operationName succeeded")
        } else {
            Log.w(MdmConstants.LOG_TAG, "$operationName failed [$errorCode]: $errorMessage")
        }
        return entry
    }

    /** Newest first. */
    fun getEntries(limit: Int? = null): List<OperationLogEntry> = synchronized(entries) {
        if (limit == null) entries.toList() else entries.take(limit)
    }

    companion object {
        private const val DEFAULT_CAPACITY = 500

        /**
         * Process-wide instance, shared with components Android instantiates
         * itself (broadcast receivers) and therefore cannot inject.
         */
        val shared: MdmLogger by lazy { MdmLogger() }
    }
}
