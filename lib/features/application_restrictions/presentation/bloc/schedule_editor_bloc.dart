import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/application_schedule.dart';
import '../../domain/usecases/save_schedule_use_case.dart';

part 'schedule_editor_event.dart';
part 'schedule_editor_state.dart';

class ScheduleEditorBloc
    extends Bloc<ScheduleEditorEvent, ScheduleEditorState> {
  ScheduleEditorBloc({
    required ScheduleEditorArgs args,
    required this._saveSchedule,
  }) : super(ScheduleEditorState.fromArgs(args)) {
    on<ScheduleStartTimeChanged>(
      (event, emit) =>
          emit(_edited(state.copyWith(startMinuteOfDay: event.minuteOfDay))),
    );
    on<ScheduleEndTimeChanged>(
      (event, emit) =>
          emit(_edited(state.copyWith(endMinuteOfDay: event.minuteOfDay))),
    );
    on<ScheduleDayToggled>((event, emit) {
      final days = {...state.daysOfWeek};
      if (!days.remove(event.dayOfWeek)) days.add(event.dayOfWeek);
      emit(_edited(state.copyWith(daysOfWeek: days)));
    });
    on<ScheduleEnabledChanged>(
      (event, emit) => emit(_edited(state.copyWith(enabled: event.enabled))),
    );
    on<ScheduleSubmitted>(_onSubmitted);
  }

  final SaveScheduleUseCase _saveSchedule;

  static ScheduleEditorState _edited(ScheduleEditorState state) =>
      state.copyWith(
        submitStatus: ScheduleSubmitStatus.editing,
        errorMessage: () => null,
      );

  Future<void> _onSubmitted(
    ScheduleSubmitted event,
    Emitter<ScheduleEditorState> emit,
  ) async {
    if (state.isSubmitting) return;
    final validationError = state.validationError;
    if (validationError != null) {
      emit(
        state.copyWith(
          submitStatus: ScheduleSubmitStatus.failure,
          errorMessage: () => validationError,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        submitStatus: ScheduleSubmitStatus.submitting,
        errorMessage: () => null,
      ),
    );
    final result = await _saveSchedule(
      ApplicationSchedule(
        id: state.scheduleId,
        packageName: state.packageName,
        startMinuteOfDay: state.startMinuteOfDay,
        endMinuteOfDay: state.endMinuteOfDay,
        daysOfWeek: state.daysOfWeek.toList()..sort(),
        enabled: state.enabled,
      ),
    );
    emit(switch (result) {
      Success() => state.copyWith(submitStatus: ScheduleSubmitStatus.success),
      FailureResult(:final failure) => state.copyWith(
        submitStatus: ScheduleSubmitStatus.failure,
        errorMessage: () => failure.message,
      ),
    });
  }
}
