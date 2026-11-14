part of 'schedule_editor_bloc.dart';

enum ScheduleSubmitStatus { editing, submitting, success, failure }

/// What the editor was opened for: a new schedule for an application, or an
/// existing schedule to change.
class ScheduleEditorArgs extends Equatable {
  const ScheduleEditorArgs.create({
    required this.packageName,
    required this.applicationName,
  }) : existing = null;

  ScheduleEditorArgs.edit(ApplicationSchedule schedule)
    : existing = schedule,
      packageName = schedule.packageName,
      applicationName = schedule.displayName;

  final ApplicationSchedule? existing;
  final String packageName;
  final String applicationName;

  @override
  List<Object?> get props => [existing, packageName, applicationName];
}

final class ScheduleEditorState extends Equatable {
  const ScheduleEditorState({
    required this.packageName,
    required this.applicationName,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.daysOfWeek,
    required this.enabled,
    this.scheduleId,
    this.submitStatus = ScheduleSubmitStatus.editing,
    this.errorMessage,
  });

  factory ScheduleEditorState.fromArgs(ScheduleEditorArgs args) {
    final existing = args.existing;
    return ScheduleEditorState(
      scheduleId: existing?.id,
      packageName: args.packageName,
      applicationName: args.applicationName,
      startMinuteOfDay: existing?.startMinuteOfDay ?? 9 * 60,
      endMinuteOfDay: existing?.endMinuteOfDay ?? 18 * 60,
      daysOfWeek: existing == null
          ? const {1, 2, 3, 4, 5}
          : existing.daysOfWeek.toSet(),
      enabled: existing?.enabled ?? true,
    );
  }

  final int? scheduleId;
  final String packageName;
  final String applicationName;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final Set<int> daysOfWeek;
  final bool enabled;
  final ScheduleSubmitStatus submitStatus;
  final String? errorMessage;

  bool get isEditingExisting => scheduleId != null;
  bool get crossesMidnight => endMinuteOfDay < startMinuteOfDay;
  bool get isSubmitting => submitStatus == ScheduleSubmitStatus.submitting;

  /// Why the current input cannot be saved, or null when it is valid.
  String? get validationError {
    if (daysOfWeek.isEmpty) return 'Select at least one day.';
    if (startMinuteOfDay == endMinuteOfDay) {
      return 'Start and end times must differ.';
    }
    return null;
  }

  ScheduleEditorState copyWith({
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    Set<int>? daysOfWeek,
    bool? enabled,
    ScheduleSubmitStatus? submitStatus,
    String? Function()? errorMessage,
  }) => ScheduleEditorState(
    scheduleId: scheduleId,
    packageName: packageName,
    applicationName: applicationName,
    startMinuteOfDay: startMinuteOfDay ?? this.startMinuteOfDay,
    endMinuteOfDay: endMinuteOfDay ?? this.endMinuteOfDay,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    enabled: enabled ?? this.enabled,
    submitStatus: submitStatus ?? this.submitStatus,
    errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
  );

  @override
  List<Object?> get props => [
    scheduleId,
    packageName,
    applicationName,
    startMinuteOfDay,
    endMinuteOfDay,
    daysOfWeek,
    enabled,
    submitStatus,
    errorMessage,
  ];
}
