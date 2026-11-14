import 'package:equatable/equatable.dart';

/// What security actions the device currently permits this app to perform.
class DeviceSecurityStatus extends Equatable {
  const DeviceSecurityStatus({
    required this.isDeviceOwner,
    required this.isDeviceAdminActive,
    required this.canLockDevice,
    required this.canWipeDevice,
    required this.isLockScreenSecured,
  });

  final bool isDeviceOwner;
  final bool isDeviceAdminActive;

  /// Locking needs an active device administrator.
  final bool canLockDevice;

  /// Factory reset needs Device Owner.
  final bool canWipeDevice;

  /// Whether a PIN, pattern or password protects the lock screen.
  final bool isLockScreenSecured;

  @override
  List<Object?> get props => [
    isDeviceOwner,
    isDeviceAdminActive,
    canLockDevice,
    canWipeDevice,
    isLockScreenSecured,
  ];
}
