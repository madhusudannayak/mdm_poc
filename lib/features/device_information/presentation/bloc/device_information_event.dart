part of 'device_information_bloc.dart';

sealed class DeviceInformationEvent extends Equatable {
  const DeviceInformationEvent();

  @override
  List<Object?> get props => [];
}

/// First load when the page opens.
final class DeviceInformationRequested extends DeviceInformationEvent {
  const DeviceInformationRequested();
}

/// User-triggered reload; keeps the current data visible while loading.
final class DeviceInformationRefreshed extends DeviceInformationEvent {
  const DeviceInformationRefreshed();
}
