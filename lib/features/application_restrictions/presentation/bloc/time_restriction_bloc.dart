import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/application_schedule.dart';
import '../../domain/usecases/get_schedule_overview_use_case.dart';
import '../../domain/usecases/remove_schedule_use_case.dart';
import '../../domain/usecases/set_schedule_enabled_use_case.dart';
import '../../domain/usecases/synchronize_schedules_use_case.dart';

part 'time_restriction_event.dart';
part 'time_restriction_state.dart';

class TimeRestrictionBloc
    extends Bloc<TimeRestrictionEvent, TimeRestrictionState> {
  TimeRestrictionBloc({
    required this._getOverview,
    required this._synchronize,
    required this._setEnabled,
    required this._remove,
  }) : super(const TimeRestrictionState()) {
    on<TimeRestrictionsRequested>(_onRequested);
    on<TimeRestrictionsSyncRequested>(_onSyncRequested);
    on<TimeRestrictionEnabledChanged>(
      (event, emit) => _runAction(
        emit,
        () => _setEnabled(event.scheduleId, enabled: event.enabled),
        successMessage: event.enabled
            ? 'Schedule enabled'
            : 'Schedule disabled',
      ),
    );
    on<TimeRestrictionDeleteConfirmed>(
      (event, emit) => _runAction(
        emit,
        () => _remove(event.scheduleId),
        successMessage: 'Schedule deleted',
      ),
    );
  }

  final GetScheduleOverviewUseCase _getOverview;
  final SynchronizeSchedulesUseCase _synchronize;
  final SetScheduleEnabledUseCase _setEnabled;
  final RemoveScheduleUseCase _remove;

  Future<void> _onRequested(
    TimeRestrictionsRequested event,
    Emitter<TimeRestrictionState> emit,
  ) async {
    final previous = state.overview;
    if (previous == null) emit(const TimeRestrictionState());
    emit(await _load());
  }

  Future<void> _onSyncRequested(
    TimeRestrictionsSyncRequested event,
    Emitter<TimeRestrictionState> emit,
  ) async {
    if (state.isActionInProgress) return;
    emit(_inProgress());
    final result = await _synchronize();
    emit(
      await _load(
        actionStatus: switch (result) {
          Success(:final value) when value.failures.isEmpty =>
            TimeRestrictionActionStatus.success,
          _ => TimeRestrictionActionStatus.failure,
        },
        actionMessage: switch (result) {
          Success(:final value) => value.summary,
          FailureResult(:final failure) => failure.message,
        },
      ),
    );
  }

  /// Runs a change, then reloads so the list shows the device's real state.
  Future<void> _runAction(
    Emitter<TimeRestrictionState> emit,
    Future<Result<void>> Function() action, {
    required String successMessage,
  }) async {
    if (state.isActionInProgress) return;
    emit(_inProgress());
    final result = await action();
    emit(
      await _load(
        actionStatus: switch (result) {
          Success() => TimeRestrictionActionStatus.success,
          FailureResult() => TimeRestrictionActionStatus.failure,
        },
        actionMessage: switch (result) {
          Success() => successMessage,
          FailureResult(:final failure) => failure.message,
        },
      ),
    );
  }

  TimeRestrictionState _inProgress() => TimeRestrictionState(
    status: state.status,
    overview: state.overview,
    failure: state.failure,
    actionStatus: TimeRestrictionActionStatus.inProgress,
  );

  Future<TimeRestrictionState> _load({
    TimeRestrictionActionStatus actionStatus = TimeRestrictionActionStatus.idle,
    String? actionMessage,
  }) async => switch (await _getOverview()) {
    Success(:final value) => TimeRestrictionState(
      status: TimeRestrictionStatus.success,
      overview: value,
      actionStatus: actionStatus,
      actionMessage: actionMessage,
    ),
    FailureResult(:final failure) => TimeRestrictionState(
      status: TimeRestrictionStatus.failure,
      failure: failure,
      actionStatus: actionStatus,
      actionMessage: actionMessage,
    ),
  };
}
