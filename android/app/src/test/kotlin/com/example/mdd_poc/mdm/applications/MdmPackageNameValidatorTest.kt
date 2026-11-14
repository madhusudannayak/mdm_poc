package com.example.mdd_poc.mdm.applications

import com.example.mdd_poc.mdm.models.MdmException
import com.example.mdd_poc.mdm.utils.MdmConstants.ErrorCodes
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class MdmPackageNameValidatorTest {

    @Test
    fun `accepts real package names`() {
        assertTrue(MdmPackageNameValidator.isValid("com.google.android.youtube"))
        assertTrue(MdmPackageNameValidator.isValid("com.example.mdd_poc"))
    }

    @Test
    fun `rejects malformed or hostile input`() {
        listOf(null, "", "youtube", "com..app", "1com.app", "com.app;rm -rf", "com.app ", "a".repeat(300) + ".b")
            .forEach { assertFalse("accepted: $it", MdmPackageNameValidator.isValid(it)) }
    }

    @Test
    fun `require throws INVALID_ARGUMENT`() {
        val error = assertThrows(MdmException::class.java) {
            MdmPackageNameValidator.require("not a package")
        }
        assertEquals(ErrorCodes.INVALID_ARGUMENT, error.errorCode)
    }
}
