import 'package:equatable/equatable.dart';

import 'device_status_models.dart';
import 'map_reader.dart';

/// Device details read from native Android APIs. Nullable fields are values
/// Android could not provide on this device; they are never substituted.
class DeviceInformationModel extends Equatable {
  const DeviceInformationModel({
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

  factory DeviceInformationModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'DeviceInformation');
    return DeviceInformationModel(
      manufacturer: reader.string('manufacturer'),
      model: reader.string('model'),
      brand: reader.string('brand'),
      deviceName: reader.stringOrNull('deviceName'),
      androidVersion: reader.string('androidVersion'),
      sdkVersion: reader.integer('sdkVersion'),
      securityPatchLevel: reader.stringOrNull('securityPatchLevel'),
      buildFingerprint: reader.string('buildFingerprint'),
      appVersionName: reader.stringOrNull('appVersionName'),
      appVersionCode: reader.integerOrNull('appVersionCode'),
      isDeviceOwner: reader.boolean('isDeviceOwner'),
      isDeviceAdminActive: reader.boolean('isDeviceAdminActive'),
      managementMode: ManagementMode.fromWire(reader.string('managementMode')),
      batteryPercentage: reader.integerOrNull('batteryPercentage'),
    );
  }

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
