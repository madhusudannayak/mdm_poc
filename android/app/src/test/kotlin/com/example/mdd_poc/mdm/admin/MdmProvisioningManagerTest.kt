package com.example.mdd_poc.mdm.admin

import com.example.mdd_poc.mdm.models.ProvisioningState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class MdmProvisioningManagerTest {

    private fun resolve(
        supported: Boolean = true,
        deviceOwner: Boolean = false,
        profileOwner: Boolean = false,
        adminActive: Boolean = false,
        completionRecorded: Boolean = false,
    ) = MdmProvisioningManager.resolve(
        isDeviceAdminSupported = supported,
        isDeviceOwner = deviceOwner,
        isProfileOwner = profileOwner,
        isDeviceAdminActive = adminActive,
        provisioningCompletionRecorded = completionRecorded,
    )

    @Test
    fun `no role is not provisioned`() {
        val resolution = resolve()
        assertEquals(ProvisioningState.NOT_PROVISIONED, resolution.state)
        assertNull(resolution.failureReason)
    }

    @Test
    fun `active admin alone is never reported as device owner`() {
        assertEquals(ProvisioningState.DEVICE_ADMIN_ACTIVE, resolve(adminActive = true).state)
    }

    @Test
    fun `device owner is reported as device owner`() {
        val resolution = resolve(deviceOwner = true, adminActive = true)
        assertEquals(ProvisioningState.DEVICE_OWNER_ACTIVE, resolution.state)
        assertNull(resolution.failureReason)
    }

    @Test
    fun `unsupported device fails provisioning with a reason`() {
        val resolution = resolve(supported = false)
        assertEquals(ProvisioningState.PROVISIONING_FAILED, resolution.state)
        assertNotNull(resolution.failureReason)
    }

    @Test
    fun `profile owner is a failed device owner provisioning`() {
        val resolution = resolve(profileOwner = true, adminActive = true)
        assertEquals(ProvisioningState.PROVISIONING_FAILED, resolution.state)
        assertNotNull(resolution.failureReason)
    }

    @Test
    fun `completed provisioning without device owner is a failure`() {
        val resolution = resolve(adminActive = true, completionRecorded = true)
        assertEquals(ProvisioningState.PROVISIONING_FAILED, resolution.state)
        assertNotNull(resolution.failureReason)
    }
}
