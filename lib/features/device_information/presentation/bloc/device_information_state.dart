part of 'device_information_bloc.dart';

enum DeviceInformationStatus { initial, loading, success, failure }

final class DeviceInformationState extends Equatable {
  const DeviceInformationState({
    this.status = DeviceInformationStatus.initial,
    this.information,
    this.failure,
    this.isRefreshing = false,
  });

  final DeviceInformationStatus status;
  final DeviceInformation? information;
  final Failure? failure;
  final bool isRefreshing;

  @override
  List<Object?> get props => [status, information, failure, isRefreshing];
}
