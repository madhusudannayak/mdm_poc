import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/managed_application.dart';
import '../../domain/usecases/allow_application_use_case.dart';
import '../../domain/usecases/block_application_use_case.dart';
import '../../domain/usecases/get_application_details_use_case.dart';
import '../../domain/usecases/set_application_hidden_use_case.dart';

part 'application_details_event.dart';
part 'application_details_state.dart';

class ApplicationDetailsBloc
    extends Bloc<ApplicationDetailsEvent, ApplicationDetailsState> {
  ApplicationDetailsBloc({
    required this.packageName,
    required this._getApplicationDetails,
    required this._blockApplication,
    required this._allowApplication,
    required this._setApplicationHidden,
  }) : super(const ApplicationDetailsState()) {
    on<ApplicationDetailsRequested>(_onRequested);
    on<ApplicationBlockConfirmed>(
      (event, emit) => _runAction(
        emit,
        () => _blockApplication(packageName),
        successMessage: 'Application blocked',
      ),
    );
    on<ApplicationAllowConfirmed>(
      (event, emit) => _runAction(
        emit,
        () => _allowApplication(packageName),
        successMessage: 'Application allowed',
        successMessageFor: (application) => application.isSuspended
            ? 'Allowed, but a time restriction keeps it suspended for now'
            : 'Application allowed',
      ),
    );
    on<ApplicationHiddenChangeConfirmed>(
      (event, emit) => _runAction(
        emit,
        () => _setApplicationHidden(packageName, hidden: event.hidden),
        successMessage: event.hidden
            ? 'Application hidden'
            : 'Application unhidden',
      ),
    );
  }

  final String packageName;
  final GetApplicationDetailsUseCase _getApplicationDetails;
  final BlockApplicationUseCase _blockApplication;
  final AllowApplicationUseCase _allowApplication;
  final SetApplicationHiddenUseCase _setApplicationHidden;

  Future<void> _onRequested(
    ApplicationDetailsRequested event,
    Emitter<ApplicationDetailsState> emit,
  ) async {
    emit(const ApplicationDetailsState());
    emit(switch (await _getApplicationDetails(packageName)) {
      Success(:final value) => ApplicationDetailsState(
        status: ApplicationDetailsStatus.success,
        application: value,
      ),
      FailureResult(:final failure) => ApplicationDetailsState(
        status: ApplicationDetailsStatus.failure,
        failure: failure,
      ),
    });
  }

  /// Runs a management action, then re-reads the application from the device
  /// so the screen shows the state Android actually applied. Success is only
  /// reported after the native call has succeeded.
  Future<void> _runAction(
    Emitter<ApplicationDetailsState> emit,
    Future<Result<void>> Function() action, {
    required String successMessage,
    String Function(ManagedApplication application)? successMessageFor,
  }) async {
    final current = state.application;
    if (current == null || state.isActionInProgress) return;
    emit(
      ApplicationDetailsState(
        status: ApplicationDetailsStatus.success,
        application: current,
        actionStatus: ApplicationActionStatus.inProgress,
      ),
    );

    final actionResult = await action();
    final actionFailure = switch (actionResult) {
      Success() => null,
      FailureResult(:final failure) => failure,
    };

    switch (await _getApplicationDetails(packageName)) {
      case Success(:final value):
        emit(
          ApplicationDetailsState(
            status: ApplicationDetailsStatus.success,
            application: value,
            actionStatus: actionFailure == null
                ? ApplicationActionStatus.success
                : ApplicationActionStatus.failure,
            actionMessage:
                actionFailure?.message ??
                successMessageFor?.call(value) ??
                successMessage,
          ),
        );
      case FailureResult(:final failure):
        emit(
          ApplicationDetailsState(
            status: ApplicationDetailsStatus.failure,
            failure: actionFailure ?? failure,
          ),
        );
    }
  }
}
