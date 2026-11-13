import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// Provisioning state of this application, resolved natively.
///
/// [deviceAdminActive] never implies [deviceOwnerActive]: an active Device
/// Administrator has none of the Device Owner privileges.
enum ProvisioningState {
  notProvisioned('NOT_PROVISIONED'),
  deviceAdminActive('DEVICE_ADMIN_ACTIVE'),
  deviceOwnerActive('DEVICE_OWNER_ACTIVE'),
  provisioningFailed('PROVISIONING_FAILED');

  const ProvisioningState(this.wireValue);

  final String wireValue;

  static ProvisioningState fromWire(String value) => values.firstWhere(
    (state) => state.wireValue == value,
    orElse: () => ProvisioningState.provisioningFailed,
  );
}

class ProvisioningStatusModel extends Equatable {
  const ProvisioningStatusModel({
    required this.state,
    required this.isDeviceOwner,
    required this.isProfileOwner,
    required this.isDeviceAdminActive,
    required this.isDeviceAdminSupported,
    required this.adminComponent,
    required this.adbProvisioningCommand,
    this.failureReason,
    this.lastAdminEvent,
    this.lastAdminEventAt,
    this.provisioningCompletedAt,
  });

  factory ProvisioningStatusModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'ProvisioningStatus');
    return ProvisioningStatusModel(
      state: ProvisioningState.fromWire(reader.string('status')),
      isDeviceOwner: reader.boolean('isDeviceOwner'),
      isProfileOwner: reader.boolean('isProfileOwner'),
      isDeviceAdminActive: reader.boolean('isDeviceAdminActive'),
      isDeviceAdminSupported: reader.boolean('isDeviceAdminSupported'),
      adminComponent: reader.string('adminComponent'),
      adbProvisioningCommand: reader.string('adbProvisioningCommand'),
      failureReason: reader.stringOrNull('failureReason'),
      lastAdminEvent: reader.stringOrNull('lastAdminEvent'),
      lastAdminEventAt: reader.integerOrNull('lastAdminEventAt'),
      provisioningCompletedAt: reader.integerOrNull('provisioningCompletedAt'),
    );
  }

  final ProvisioningState state;
  final bool isDeviceOwner;
  final bool isProfileOwner;
  final bool isDeviceAdminActive;
  final bool isDeviceAdminSupported;
  final String adminComponent;

  /// `adb shell dpm set-device-owner <component>` built natively from the
  /// real receiver component, for display in the provisioning instructions.
  final String adbProvisioningCommand;
  final String? failureReason;

  /// Last DeviceAdminReceiver lifecycle callback recorded on the device.
  final String? lastAdminEvent;
  final int? lastAdminEventAt;
  final int? provisioningCompletedAt;

  @override
  List<Object?> get props => [
    state,
    isDeviceOwner,
    isProfileOwner,
    isDeviceAdminActive,
    isDeviceAdminSupported,
    adminComponent,
    adbProvisioningCommand,
    failureReason,
    lastAdminEvent,
    lastAdminEventAt,
    provisioningCompletedAt,
  ];
}
