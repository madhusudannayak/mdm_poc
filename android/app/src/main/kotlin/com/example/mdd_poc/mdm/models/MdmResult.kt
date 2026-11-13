package com.example.mdd_poc.mdm.models

/**
 * Standard reply envelope for every channel method:
 * `{success, message, data, errorCode}`.
 *
 * [data] must only contain values the Flutter StandardMessageCodec can
 * encode (null, Boolean, Number, String, ByteArray, List, Map).
 */
data class MdmResult(
    val success: Boolean,
    val message: String,
    val data: Any?,
    val errorCode: String?,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "success" to success,
        "message" to message,
        "data" to data,
        "errorCode" to errorCode,
    )

    companion object {
        fun success(data: Any? = null, message: String = "Operation completed"): MdmResult =
            MdmResult(success = true, message = message, data = data, errorCode = null)

        fun failure(errorCode: String, message: String): MdmResult =
            MdmResult(success = false, message = message, data = null, errorCode = errorCode)
    }
}

/** A native MDM operation failed for a known, reportable reason. */
class MdmException(val errorCode: String, override val message: String) : Exception(message)
