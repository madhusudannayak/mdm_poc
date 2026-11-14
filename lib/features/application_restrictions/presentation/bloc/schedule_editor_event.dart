part of 'schedule_editor_bloc.dart';

sealed class ScheduleEditorEvent extends Equatable {
  const ScheduleEditorEvent();

  @override
  List<Object?> get props => [];
}

final class ScheduleStartTimeChanged extends ScheduleEditorEvent {
  const ScheduleStartTimeChanged(this.minuteOfDay);

  final int minuteOfDay;

  @override
  List<Object?> get props => [minuteOfDay];
}

final class ScheduleEndTimeChanged extends ScheduleEditorEvent {
  const ScheduleEndTimeChanged(this.minuteOfDay);

  final int minuteOfDay;

  @override
  List<Object?> get props => [minuteOfDay];
}

final class ScheduleDayToggled extends ScheduleEditorEvent {
  const ScheduleDayToggled(this.dayOfWeek);

  final int dayOfWeek;

  @override
  List<Object?> get props => [dayOfWeek];
}

final class ScheduleEnabledChanged extends ScheduleEditorEvent {
  const ScheduleEnabledChanged({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class ScheduleSubmitted extends ScheduleEditorEvent {
  const ScheduleSubmitted();
}
