/// Wire-format payloads as the native layer sends them.
Map<String, Object?> deviceInformationMap({
  String? deviceName = 'Test Pixel',
  int? batteryPercentage = 87,
  bool isDeviceOwner = true,
}) => {
  'manufacturer': 'Google',
  'model': 'Pixel 7 Pro',
  'brand': 'google',
  'deviceName': deviceName,
  'androidVersion': '16',
  'sdkVersion': 36,
  'securityPatchLevel': '2026-10-05',
  'buildFingerprint': 'google/cheetah/cheetah:16/test-keys',
  'appVersionName': '1.0.0',
  'appVersionCode': 1,
  'isDeviceOwner': isDeviceOwner,
  'isDeviceAdminActive': isDeviceOwner,
  'managementMode': isDeviceOwner ? 'FULLY_MANAGED' : 'UNMANAGED',
  'batteryPercentage': batteryPercentage,
};

Map<String, Object?> provisioningStatusMap({
  String status = 'NOT_PROVISIONED',
  bool isDeviceOwner = false,
  bool isDeviceAdminActive = false,
  String? failureReason,
}) => {
  'status': status,
  'isDeviceOwner': isDeviceOwner,
  'isProfileOwner': false,
  'isDeviceAdminActive': isDeviceAdminActive,
  'isDeviceAdminSupported': true,
  'adminComponent': 'com.example.mdd_poc/.mdm.admin.MdmDeviceAdminReceiver',
  'adbProvisioningCommand':
      'adb shell dpm set-device-owner '
      'com.example.mdd_poc/.mdm.admin.MdmDeviceAdminReceiver',
  'failureReason': failureReason,
  'lastAdminEvent': null,
  'lastAdminEventAt': null,
  'provisioningCompletedAt': null,
};

Map<String, Object?> managementStatusMap({
  String mode = 'UNMANAGED',
  bool isDeviceOwner = false,
  bool isDeviceAdminActive = false,
}) => {
  'managementMode': mode,
  'isDeviceOwner': isDeviceOwner,
  'isProfileOwner': false,
  'isDeviceAdminActive': isDeviceAdminActive,
  'isDeviceAdminSupported': true,
  'adminComponent': 'com.example.mdd_poc/.mdm.admin.MdmDeviceAdminReceiver',
};

Map<String, Object?> applicationMap({
  String packageName = 'com.google.android.youtube',
  String applicationName = 'YouTube',
  bool isSystemApplication = false,
  bool isSuspended = false,
  bool isHidden = false,
  String policyStatus = 'UNSPECIFIED',
}) => {
  'packageName': packageName,
  'applicationName': applicationName,
  'versionName': '1.2.3',
  'versionCode': 123,
  'isSystemApplication': isSystemApplication,
  'isEnabled': true,
  'isSuspended': isSuspended,
  'isHidden': isHidden,
  'isUninstallBlocked': false,
  'installerPackageName': 'com.android.vending',
  'policyStatus': policyStatus,
  'iconPng': null,
};

Map<String, Object?> successEnvelope(Object? data) => {
  'success': true,
  'message': 'Operation completed',
  'data': data,
  'errorCode': null,
};

Map<String, Object?> failureEnvelope(String code, String message) => {
  'success': false,
  'message': message,
  'data': null,
  'errorCode': code,
};
