import 'package:equatable/equatable.dart';

import '../../../../core/platform/models/device_status_models.dart';

/// Device details shown on the Device Information screen. Null fields are
/// values Android did not provide.
class DeviceInformation extends Equatable {
  const DeviceInformation({
    required this.manufacturer,
    required this.model,
    required this.brand,
    required this.androidVersion,
    required this.sdkVersion,
    required this.buildFingerprint,
    required this.isDeviceOwner,
    required this.isDeviceAdminActive,
    required this.managementMode,
    this.deviceName,
    this.securityPatchLevel,
    this.appVersionName,
    this.appVersionCode,
    this.batteryPercentage,
  });

  final String manufacturer;
  final String model;
  final String brand;
  final String? deviceName;
  final String androidVersion;
  final int sdkVersion;
  final String? securityPatchLevel;
  final String buildFingerprint;
  final String? appVersionName;
  final int? appVersionCode;
  final bool isDeviceOwner;
  final bool isDeviceAdminActive;
  final ManagementMode managementMode;
  final int? batteryPercentage;

  /// "1.0.0 (1)" style label, or null when the version is unavailable.
  String? get appVersionLabel {
    final name = appVersionName;
    final code = appVersionCode;
    if (name == null && code == null) return null;
    if (code == null) return name;
    return name == null ? '($code)' : '$name ($code)';
  }

  @override
  List<Object?> get props => [
    manufacturer,
    model,
    brand,
    deviceName,
    androidVersion,
    sdkVersion,
    securityPatchLevel,
    buildFingerprint,
    appVersionName,
    appVersionCode,
    isDeviceOwner,
    isDeviceAdminActive,
    managementMode,
    batteryPercentage,
  ];
}
