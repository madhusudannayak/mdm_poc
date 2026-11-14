package com.example.mdd_poc.mdm.applications

import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes

/**
 * Validates package names received over the channel before they reach any
 * Android API. Mirrors `MdmConstants.packageNamePattern` on the Dart side.
 */
object MdmPackageNameValidator {
    private const val MAX_LENGTH = 255
    private val pattern = Regex("^[a-zA-Z][a-zA-Z0-9_]*(\\.[a-zA-Z][a-zA-Z0-9_]*)+$")

    fun isValid(packageName: String?): Boolean =
        packageName != null &&
            packageName.length <= MAX_LENGTH &&
            pattern.matches(packageName)

    /** Returns [packageName] or throws `INVALID_ARGUMENT`. */
    fun require(packageName: String?): String {
        if (!isValid(packageName)) {
            throw MdmException(
                ErrorCodes.INVALID_ARGUMENT,
                "A valid Android package name is required",
            )
        }
        return packageName!!
    }
}
