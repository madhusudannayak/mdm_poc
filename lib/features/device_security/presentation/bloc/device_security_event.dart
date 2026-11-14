part of 'device_security_bloc.dart';

sealed class DeviceSecurityEvent extends Equatable {
  const DeviceSecurityEvent();

  @override
  List<Object?> get props => [];
}

final class DeviceSecurityRequested extends DeviceSecurityEvent {
  const DeviceSecurityRequested();
}

/// Dispatched only after the user confirmed locking the device.
final class DeviceLockConfirmed extends DeviceSecurityEvent {
  const DeviceLockConfirmed();
}

/// Dispatched only after the user pressed CONFIRM FACTORY RESET.
final class FactoryResetConfirmed extends DeviceSecurityEvent {
  const FactoryResetConfirmed();
}
