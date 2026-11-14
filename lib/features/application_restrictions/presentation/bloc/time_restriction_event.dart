part of 'time_restriction_bloc.dart';

sealed class TimeRestrictionEvent extends Equatable {
  const TimeRestrictionEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads) schedules and their live state.
final class TimeRestrictionsRequested extends TimeRestrictionEvent {
  const TimeRestrictionsRequested();
}

/// Manual synchronization button.
final class TimeRestrictionsSyncRequested extends TimeRestrictionEvent {
  const TimeRestrictionsSyncRequested();
}

final class TimeRestrictionEnabledChanged extends TimeRestrictionEvent {
  const TimeRestrictionEnabledChanged({
    required this.scheduleId,
    required this.enabled,
  });

  final int scheduleId;
  final bool enabled;

  @override
  List<Object?> get props => [scheduleId, enabled];
}

/// Dispatched only after the user confirmed the deletion.
final class TimeRestrictionDeleteConfirmed extends TimeRestrictionEvent {
  const TimeRestrictionDeleteConfirmed(this.scheduleId);

  final int scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}
