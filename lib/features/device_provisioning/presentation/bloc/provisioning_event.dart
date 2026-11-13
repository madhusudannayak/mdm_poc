part of 'provisioning_bloc.dart';

sealed class ProvisioningEvent extends Equatable {
  const ProvisioningEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads) the provisioning status from the device.
final class ProvisioningStatusRequested extends ProvisioningEvent {
  const ProvisioningStatusRequested();
}
