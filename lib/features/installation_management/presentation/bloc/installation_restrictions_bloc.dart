import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/installation_restriction_status.dart';
import '../../domain/usecases/get_installation_restriction_status_use_case.dart';
import '../../domain/usecases/set_installations_blocked_use_case.dart';
import '../../domain/usecases/set_uninstall_blocked_use_case.dart';
import '../../domain/usecases/set_unknown_sources_blocked_use_case.dart';

part 'installation_restrictions_event.dart';
part 'installation_restrictions_state.dart';

class InstallationRestrictionsBloc
    extends Bloc<InstallationRestrictionsEvent, InstallationRestrictionsState> {
  InstallationRestrictionsBloc({
    required this._getStatus,
    required this._setInstallationsBlocked,
    required this._setUnknownSourcesBlocked,
    required this._setUninstallBlocked,
  }) : super(const InstallationRestrictionsState()) {
    on<InstallationRestrictionsRequested>(
      (event, emit) async => emit(await _load()),
    );
    on<InstallationBlockChangeConfirmed>(
      (event, emit) => _runAction(
        emit,
        () => _setInstallationsBlocked(blocked: event.blocked),
        successMessage: event.blocked
            ? 'All application installations are blocked'
            : 'Application installations are allowed',
      ),
    );
    on<UnknownSourcesBlockChangeConfirmed>(
      (event, emit) => _runAction(
        emit,
        () => _setUnknownSourcesBlocked(blocked: event.blocked),
        successMessage: event.blocked
            ? 'Installation from unknown sources is blocked'
            : 'Installation from unknown sources is allowed',
      ),
    );
    on<UninstallBlockChangeConfirmed>(
      (event, emit) => _runAction(
        emit,
        () => _setUninstallBlocked(event.packageName, blocked: event.blocked),
        successMessage: event.blocked
            ? 'Uninstall blocked for ${event.packageName}'
            : 'Uninstall allowed for ${event.packageName}',
      ),
    );
  }

  final GetInstallationRestrictionStatusUseCase _getStatus;
  final SetInstallationsBlockedUseCase _setInstallationsBlocked;
  final SetUnknownSourcesBlockedUseCase _setUnknownSourcesBlocked;
  final SetUninstallBlockedUseCase _setUninstallBlocked;

  /// Runs a change, then re-reads the effective policy from the device so
  /// the screen never shows a state Android did not apply.
  Future<void> _runAction(
    Emitter<InstallationRestrictionsState> emit,
    Future<Result<Object?>> Function() action, {
    required String successMessage,
  }) async {
    if (state.isActionInProgress) return;
    emit(
      InstallationRestrictionsState(
        restrictions: state.restrictions,
        failure: state.failure,
        actionStatus: InstallationActionStatus.inProgress,
      ),
    );
    final result = await action();
    emit(
      await _load(
        actionStatus: switch (result) {
          Success() => InstallationActionStatus.success,
          FailureResult() => InstallationActionStatus.failure,
        },
        actionMessage: switch (result) {
          Success() => successMessage,
          FailureResult(:final failure) => failure.message,
        },
      ),
    );
  }

  Future<InstallationRestrictionsState> _load({
    InstallationActionStatus actionStatus = InstallationActionStatus.idle,
    String? actionMessage,
  }) async => switch (await _getStatus()) {
    Success(:final value) => InstallationRestrictionsState(
      restrictions: value,
      actionStatus: actionStatus,
      actionMessage: actionMessage,
    ),
    FailureResult(:final failure) => InstallationRestrictionsState(
      failure: failure,
      actionStatus: actionStatus,
      actionMessage: actionMessage,
    ),
  };
}
