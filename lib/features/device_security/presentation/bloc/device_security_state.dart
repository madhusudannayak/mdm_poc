part of 'device_security_bloc.dart';

enum DeviceSecurityAction { none, lock, factoryReset }

enum DeviceSecurityActionStatus { idle, inProgress, success, failure }

final class DeviceSecurityState extends Equatable {
  const DeviceSecurityState({
    this.security,
    this.failure,
    this.action = DeviceSecurityAction.none,
    this.actionStatus = DeviceSecurityActionStatus.idle,
    this.actionMessage,
  });

  /// Null until loaded, and after a failed load.
  final DeviceSecurityStatus? security;
  final Failure? failure;
  final DeviceSecurityAction action;
  final DeviceSecurityActionStatus actionStatus;
  final String? actionMessage;

  bool get isActionInProgress =>
      actionStatus == DeviceSecurityActionStatus.inProgress;

  /// A confirmed factory reset is waiting for the device to restart.
  bool get isFactoryResetPending =>
      action == DeviceSecurityAction.factoryReset && isActionInProgress;

  /// Why the last confirmed factory reset did not happen, if it failed.
  String? get factoryResetError =>
      action == DeviceSecurityAction.factoryReset &&
          actionStatus == DeviceSecurityActionStatus.failure
      ? actionMessage
      : null;

  /// A factory reset was accepted by Android; the device is going away.
  bool get isFactoryResetInitiated =>
      action == DeviceSecurityAction.factoryReset &&
      actionStatus == DeviceSecurityActionStatus.success;

  @override
  List<Object?> get props => [
    security,
    failure,
    action,
    actionStatus,
    actionMessage,
  ];
}
