import 'models/application_schedule_model.dart';
import 'models/device_information_model.dart';
import 'models/device_policy_model.dart';
import 'models/device_status_models.dart';
import 'models/installation_restriction_status_model.dart';
import 'models/managed_application_model.dart';
import 'models/native_system_models.dart';
import 'models/provisioning_status_model.dart';

/// The single typed gateway to native Android device management.
///
/// Repositories depend on this interface, never on `MethodChannel`. Every
/// method either returns the real native result or throws an `MdmException`
/// carrying an error code from `MdmErrorCodes`.
abstract interface class MdmPlatformInterface {
  // --- Device information -------------------------------------------------
  Future<DeviceInformationModel> getDeviceInfo();
  Future<AndroidVersionModel> getAndroidVersion();
  Future<DeviceManagementStatusModel> getDeviceManagementStatus();
  Future<DeviceAdminStatusModel> getDeviceAdminStatus();
  Future<DeviceOwnerStatusModel> getDeviceOwnerStatus();

  // --- Device provisioning ------------------------------------------------
  Future<bool> isDeviceOwner();
  Future<bool> isDeviceAdminActive();
  Future<ProvisioningStatusModel> getProvisioningStatus();

  // --- Application management ---------------------------------------------
  Future<List<ManagedApplicationModel>> getInstalledApplications({
    bool includeSystemApplications = true,
    bool includeIcons = true,
  });
  Future<ManagedApplicationModel> getApplicationDetails(String packageName);
  Future<void> suspendApplication(String packageName);
  Future<void> unsuspendApplication(String packageName);
  Future<bool> isApplicationSuspended(String packageName);
  Future<void> setApplicationHidden(String packageName);
  Future<void> setApplicationUnhidden(String packageName);
  Future<void> setApplicationUninstallBlocked(
    String packageName, {
    required bool blocked,
  });

  // --- Installation management --------------------------------------------
  /// Blocks or allows every application installation on the device.
  Future<InstallationRestrictionStatusModel>
  setApplicationInstallationRestriction({required bool enabled});

  /// Blocks or allows installation from unknown sources only.
  Future<InstallationRestrictionStatusModel> setUnknownSourcesRestriction({
    required bool enabled,
  });
  Future<InstallationRestrictionStatusModel> getInstallationRestrictionStatus();

  // --- Device security ----------------------------------------------------
  Future<void> lockDevice();

  /// Factory resets the device. [confirmed] must be true and must originate
  /// from an explicit user confirmation.
  ///
  /// A device that resets restarts before replying, so this normally never
  /// completes. It completes with `FACTORY_RESET_NOT_PERFORMED` when the
  /// device is still running after a grace period.
  Future<void> wipeDevice({required bool confirmed});

  // --- Scheduling ---------------------------------------------------------
  Future<ApplicationScheduleModel> saveApplicationSchedule(
    ApplicationScheduleModel schedule,
  );
  Future<ApplicationScheduleModel> updateApplicationSchedule(
    ApplicationScheduleModel schedule,
  );
  Future<void> removeApplicationSchedule(int scheduleId);
  Future<List<ApplicationScheduleModel>> getApplicationSchedules();
  Future<void> enableApplicationSchedule(int scheduleId);
  Future<void> disableApplicationSchedule(int scheduleId);

  /// Re-evaluates every schedule now, corrects application state and
  /// re-arms the next transition.
  Future<ScheduleSyncReportModel> synchronizeApplicationSchedules();

  // --- Policies -----------------------------------------------------------
  Future<DevicePolicyModel> applyDevicePolicy(DevicePolicyModel policy);
  Future<void> removeDevicePolicy(String policyId);
  Future<List<DevicePolicyModel>> getActiveDevicePolicies();

  // --- System -------------------------------------------------------------
  Future<NativeCapabilitiesModel> getNativeCapabilities();
  Future<List<NativeLogEntryModel>> getNativeLogs({int? limit});
  Future<NativePermissionsModel> checkNativePermissions();
}
