package com.example.mdd_poc.mdm.models

/** Audit record of one native operation. Never contains secrets or payloads. */
data class OperationLogEntry(
    val operationId: String,
    val operationName: String,
    val packageName: String?,
    val requestTimestamp: Long,
    val executionTimestamp: Long,
    val success: Boolean,
    val errorCode: String?,
    val errorMessage: String?,
    val sdkVersion: Int,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "operationId" to operationId,
        "operationName" to operationName,
        "packageName" to packageName,
        "requestTimestamp" to requestTimestamp,
        "executionTimestamp" to executionTimestamp,
        "success" to success,
        "errorCode" to errorCode,
        "errorMessage" to errorMessage,
        "sdkVersion" to sdkVersion,
    )
}
