/// Constants shared by the Flutter side of the MDM platform contract.
///
/// The values here must stay in sync with
/// `android/.../mdm/utils/MdmConstants.kt`.
abstract final class MdmConstants {
  static const String channelName = 'com.company.mdm/device_management';

  /// Android package names: at least two dot-separated segments, each starting
  /// with a letter and containing only letters, digits and underscores.
  static final RegExp packageNamePattern = RegExp(
    r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$',
  );

  static const int maxPackageNameLength = 255;
  static const int minutesPerDay = 24 * 60;
}

/// Method names of the `com.company.mdm/device_management` channel.
abstract final class MdmMethods {
  // Device information
  static const String getDeviceInfo = 'getDeviceInfo';
  static const String getAndroidVersion = 'getAndroidVersion';
  static const String getDeviceManagementStatus = 'getDeviceManagementStatus';
  static const String getDeviceAdminStatus = 'getDeviceAdminStatus';
  static const String getDeviceOwnerStatus = 'getDeviceOwnerStatus';

  // Device provisioning
  static const String isDeviceOwner = 'isDeviceOwner';
  static const String isDeviceAdminActive = 'isDeviceAdminActive';
  static const String getProvisioningStatus = 'getProvisioningStatus';

  // Application management
  static const String getInstalledApplications = 'getInstalledApplications';
  static const String getApplicationDetails = 'getApplicationDetails';
  static const String suspendApplication = 'suspendApplication';
  static const String unsuspendApplication = 'unsuspendApplication';
  static const String isApplicationSuspended = 'isApplicationSuspended';
  static const String setApplicationHidden = 'setApplicationHidden';
  static const String setApplicationUnhidden = 'setApplicationUnhidden';
  static const String setApplicationUninstallBlocked =
      'setApplicationUninstallBlocked';

  // Installation management
  static const String setApplicationInstallationRestriction =
      'setApplicationInstallationRestriction';
  static const String setUnknownSourcesRestriction =
      'setUnknownSourcesRestriction';
  static const String getInstallationRestrictionStatus =
      'getInstallationRestrictionStatus';

  // Device security
  static const String lockDevice = 'lockDevice';
  static const String wipeDevice = 'wipeDevice';

  // Scheduling
  static const String saveApplicationSchedule = 'saveApplicationSchedule';
  static const String updateApplicationSchedule = 'updateApplicationSchedule';
  static const String removeApplicationSchedule = 'removeApplicationSchedule';
  static const String getApplicationSchedules = 'getApplicationSchedules';
  static const String enableApplicationSchedule = 'enableApplicationSchedule';
  static const String disableApplicationSchedule = 'disableApplicationSchedule';

  // Policies
  static const String applyDevicePolicy = 'applyDevicePolicy';
  static const String removeDevicePolicy = 'removeDevicePolicy';
  static const String getActiveDevicePolicies = 'getActiveDevicePolicies';

  // System
  static const String getNativeCapabilities = 'getNativeCapabilities';
  static const String getNativeLogs = 'getNativeLogs';
  static const String checkNativePermissions = 'checkNativePermissions';
}

/// Error codes returned in the `errorCode` field of the native response
/// envelope, plus the codes produced on the Dart side of the channel.
abstract final class MdmErrorCodes {
  // Produced by native code.
  static const String deviceOwnerRequired = 'DEVICE_OWNER_REQUIRED';
  static const String deviceAdminRequired = 'DEVICE_ADMIN_REQUIRED';
  static const String deviceAdminUnsupported = 'DEVICE_ADMIN_UNSUPPORTED';
  static const String invalidArgument = 'INVALID_ARGUMENT';
  static const String packageNotFound = 'PACKAGE_NOT_FOUND';
  static const String unsupportedAndroidVersion = 'UNSUPPORTED_ANDROID_VERSION';
  static const String securityException = 'SECURITY_EXCEPTION';
  static const String operationFailed = 'OPERATION_FAILED';

  // Produced by the Dart side of the channel.
  static const String nativeMethodMissing = 'NATIVE_METHOD_MISSING';
  static const String invalidResponse = 'INVALID_RESPONSE';
  static const String platformError = 'PLATFORM_ERROR';
  static const String unknown = 'UNKNOWN_ERROR';
}
