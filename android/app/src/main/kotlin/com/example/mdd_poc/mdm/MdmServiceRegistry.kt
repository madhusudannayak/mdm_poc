package com.example.mdd_poc.mdm

import android.content.Context
import com.example.mdd_poc.mdm.admin.MdmAdminManager
import com.example.mdd_poc.mdm.admin.MdmProvisioningManager
import com.example.mdd_poc.mdm.admin.MdmProvisioningStateStore
import com.example.mdd_poc.mdm.applications.MdmApplicationManager
import com.example.mdd_poc.mdm.applications.MdmApplicationPolicyStore
import com.example.mdd_poc.mdm.applications.MdmApplicationSuspensionManager
import com.example.mdd_poc.mdm.applications.MdmPackageManager
import com.example.mdd_poc.mdm.device.MdmDeviceInformationManager
import com.example.mdd_poc.mdm.device.MdmDeviceManager
import com.example.mdd_poc.mdm.device.MdmSecurityManager
import com.example.mdd_poc.mdm.policy.MdmInstallationManager
import com.example.mdd_poc.mdm.policy.MdmRestrictionManager
import com.example.mdd_poc.mdm.scheduling.MdmAlarmScheduler
import com.example.mdd_poc.mdm.scheduling.MdmScheduleManager
import com.example.mdd_poc.mdm.scheduling.MdmScheduleRepository
import com.example.mdd_poc.mdm.storage.MdmDatabase
import com.example.mdd_poc.mdm.utils.MdmLogger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

/**
 * Process-wide composition root of the native MDM services.
 *
 * The Flutter channel is only one entry point. Alarms, boot and time-change
 * broadcasts and WorkManager start the process without any activity, so the
 * services are built here once and shared by every entry point. Services
 * themselves still receive their dependencies through their constructors.
 */
class MdmServiceRegistry private constructor(context: Context) {
    private val appContext = context.applicationContext

    /** For work that must outlive a single caller (broadcasts). */
    val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    val logger: MdmLogger = MdmLogger.shared
    val adminManager = MdmAdminManager(appContext)
    val packageManager = MdmPackageManager(appContext)
    val policyStore = MdmApplicationPolicyStore(appContext)
    val suspensionManager = MdmApplicationSuspensionManager(adminManager, packageManager)
    val alarmScheduler = MdmAlarmScheduler(appContext)

    val provisioningManager =
        MdmProvisioningManager(adminManager, MdmProvisioningStateStore(appContext))
    val deviceInformationManager = MdmDeviceInformationManager(appContext, adminManager)
    val deviceManager = MdmDeviceManager(appContext, adminManager)
    val securityManager = MdmSecurityManager(appContext, adminManager, logger)
    val restrictionManager = MdmRestrictionManager(appContext, adminManager)
    val installationManager =
        MdmInstallationManager(adminManager, restrictionManager, packageManager)

    private val database: MdmDatabase by lazy { MdmDatabase.create(appContext) }

    val scheduleManager: MdmScheduleManager by lazy {
        MdmScheduleManager(
            repository = MdmScheduleRepository(database.scheduleDao()),
            adminManager = adminManager,
            packageManager = packageManager,
            suspensionManager = suspensionManager,
            policyStore = policyStore,
            alarmScheduler = alarmScheduler,
            logger = logger,
        )
    }

    val applicationManager: MdmApplicationManager by lazy {
        MdmApplicationManager(
            adminManager = adminManager,
            packageManager = packageManager,
            suspensionManager = suspensionManager,
            policyStore = policyStore,
            isTimeRestrictedNow = scheduleManager::isRestrictedNow,
        )
    }

    companion object {
        @Volatile private var instance: MdmServiceRegistry? = null

        fun get(context: Context): MdmServiceRegistry =
            instance ?: synchronized(this) {
                instance ?: MdmServiceRegistry(context).also { instance = it }
            }
    }
}
