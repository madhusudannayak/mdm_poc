import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// How this application currently manages the device, as resolved natively
/// from `DevicePolicyManager`. These are distinct Android concepts:
///
/// * [fullyManaged] - the app is Device Owner of a fully managed device.
/// * [profileOwner] - the app owns a (work) profile only.
/// * [deviceAdmin] - legacy Device Administrator; no owner privileges.
/// * [unmanaged] - the app holds no management role.
enum ManagementMode {
  fullyManaged('FULLY_MANAGED'),
  profileOwner('PROFILE_OWNER'),
  deviceAdmin('DEVICE_ADMIN'),
  unmanaged('UNMANAGED');

  const ManagementMode(this.wireValue);

  final String wireValue;

  static ManagementMode fromWire(String value) => values.firstWhere(
    (mode) => mode.wireValue == value,
    orElse: () => ManagementMode.unmanaged,
  );
}

class AndroidVersionModel extends Equatable {
  const AndroidVersionModel({
    required this.release,
    required this.sdkInt,
    required this.codename,
    this.securityPatch,
  });

  factory AndroidVersionModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'AndroidVersion');
    return AndroidVersionModel(
      release: reader.string('release'),
      sdkInt: reader.integer('sdkInt'),
      codename: reader.string('codename'),
      securityPatch: reader.stringOrNull('securityPatch'),
    );
  }

  final String release;
  final int sdkInt;
  final String codename;
  final String? securityPatch;

  @override
  List<Object?> get props => [release, sdkInt, codename, securityPatch];
}

class DeviceManagementStatusModel extends Equatable {
  const DeviceManagementStatusModel({
    required this.managementMode,
    required this.isDeviceOwner,
    required this.isProfileOwner,
    required this.isDeviceAdminActive,
    required this.isDeviceAdminSupported,
    required this.adminComponent,
  });

  factory DeviceManagementStatusModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'DeviceManagementStatus');
    return DeviceManagementStatusModel(
      managementMode: ManagementMode.fromWire(reader.string('managementMode')),
      isDeviceOwner: reader.boolean('isDeviceOwner'),
      isProfileOwner: reader.boolean('isProfileOwner'),
      isDeviceAdminActive: reader.boolean('isDeviceAdminActive'),
      isDeviceAdminSupported: reader.boolean('isDeviceAdminSupported'),
      adminComponent: reader.string('adminComponent'),
    );
  }

  final ManagementMode managementMode;
  final bool isDeviceOwner;
  final bool isProfileOwner;
  final bool isDeviceAdminActive;
  final bool isDeviceAdminSupported;

  /// Flattened `package/receiver` component of the DeviceAdminReceiver.
  final String adminComponent;

  @override
  List<Object?> get props => [
    managementMode,
    isDeviceOwner,
    isProfileOwner,
    isDeviceAdminActive,
    isDeviceAdminSupported,
    adminComponent,
  ];
}

class DeviceAdminStatusModel extends Equatable {
  const DeviceAdminStatusModel({
    required this.isActive,
    required this.isSupported,
    required this.adminComponent,
  });

  factory DeviceAdminStatusModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'DeviceAdminStatus');
    return DeviceAdminStatusModel(
      isActive: reader.boolean('isActive'),
      isSupported: reader.boolean('isSupported'),
      adminComponent: reader.string('adminComponent'),
    );
  }

  final bool isActive;
  final bool isSupported;
  final String adminComponent;

  @override
  List<Object?> get props => [isActive, isSupported, adminComponent];
}

class DeviceOwnerStatusModel extends Equatable {
  const DeviceOwnerStatusModel({
    required this.isDeviceOwner,
    required this.isProfileOwner,
    required this.packageName,
  });

  factory DeviceOwnerStatusModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'DeviceOwnerStatus');
    return DeviceOwnerStatusModel(
      isDeviceOwner: reader.boolean('isDeviceOwner'),
      isProfileOwner: reader.boolean('isProfileOwner'),
      packageName: reader.string('packageName'),
    );
  }

  final bool isDeviceOwner;
  final bool isProfileOwner;
  final String packageName;

  @override
  List<Object?> get props => [isDeviceOwner, isProfileOwner, packageName];
}
