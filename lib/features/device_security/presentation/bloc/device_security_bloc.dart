import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/device_security_status.dart';
import '../../domain/usecases/factory_reset_device_use_case.dart';
import '../../domain/usecases/get_device_security_status_use_case.dart';
import '../../domain/usecases/lock_device_use_case.dart';

part 'device_security_event.dart';
part 'device_security_state.dart';

class DeviceSecurityBloc
    extends Bloc<DeviceSecurityEvent, DeviceSecurityState> {
  DeviceSecurityBloc({
    required this._getStatus,
    required this._lockDevice,
    required this._factoryReset,
  }) : super(const DeviceSecurityState()) {
    on<DeviceSecurityRequested>(_onRequested);
    on<DeviceLockConfirmed>(_onLockConfirmed);
    on<FactoryResetConfirmed>(_onFactoryResetConfirmed);
  }

  final GetDeviceSecurityStatusUseCase _getStatus;
  final LockDeviceUseCase _lockDevice;
  final FactoryResetDeviceUseCase _factoryReset;

  Future<void> _onRequested(
    DeviceSecurityRequested event,
    Emitter<DeviceSecurityState> emit,
  ) async {
    emit(switch (await _getStatus()) {
      Success(:final value) => DeviceSecurityState(security: value),
      FailureResult(:final failure) => DeviceSecurityState(failure: failure),
    });
  }

  /// Success is only reported after the native lock call has succeeded.
  Future<void> _onLockConfirmed(
    DeviceLockConfirmed event,
    Emitter<DeviceSecurityState> emit,
  ) async {
    final security = state.security;
    if (security == null || _isBusyOrResetting) return;
    emit(_inProgress(DeviceSecurityAction.lock));
    emit(switch (await _lockDevice()) {
      Success() => _finished(
        DeviceSecurityAction.lock,
        DeviceSecurityActionStatus.success,
        security.isLockScreenSecured
            ? 'Device locked'
            : 'Screen turned off. No screen lock is configured, so the '
                  'device opens without credentials.',
      ),
      FailureResult(:final failure) => _finished(
        DeviceSecurityAction.lock,
        DeviceSecurityActionStatus.failure,
        failure.message,
      ),
    });
  }

  /// A device that resets restarts before replying, so this handler normally
  /// never finishes: the screen stays on "in progress" until the device goes
  /// down. If the device is still running, native reports a failure.
  Future<void> _onFactoryResetConfirmed(
    FactoryResetConfirmed event,
    Emitter<DeviceSecurityState> emit,
  ) async {
    if (state.security == null || _isBusyOrResetting) return;
    emit(_inProgress(DeviceSecurityAction.factoryReset));
    emit(switch (await _factoryReset()) {
      Success() => _finished(
        DeviceSecurityAction.factoryReset,
        DeviceSecurityActionStatus.success,
        'Factory reset initiated. The device will restart and erase its data.',
      ),
      FailureResult(:final failure) => _finished(
        DeviceSecurityAction.factoryReset,
        DeviceSecurityActionStatus.failure,
        failure.message,
      ),
    });
  }

  /// Once a factory reset was accepted, no further action is started.
  bool get _isBusyOrResetting =>
      state.isActionInProgress || state.isFactoryResetInitiated;

  DeviceSecurityState _inProgress(DeviceSecurityAction action) =>
      DeviceSecurityState(
        security: state.security,
        action: action,
        actionStatus: DeviceSecurityActionStatus.inProgress,
      );

  DeviceSecurityState _finished(
    DeviceSecurityAction action,
    DeviceSecurityActionStatus status,
    String message,
  ) => DeviceSecurityState(
    security: state.security,
    action: action,
    actionStatus: status,
    actionMessage: message,
  );
}
