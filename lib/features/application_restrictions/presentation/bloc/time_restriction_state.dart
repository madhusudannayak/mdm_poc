part of 'time_restriction_bloc.dart';

enum TimeRestrictionStatus { loading, success, failure }

enum TimeRestrictionActionStatus { idle, inProgress, success, failure }

final class TimeRestrictionState extends Equatable {
  const TimeRestrictionState({
    this.status = TimeRestrictionStatus.loading,
    this.overview,
    this.failure,
    this.actionStatus = TimeRestrictionActionStatus.idle,
    this.actionMessage,
  });

  final TimeRestrictionStatus status;
  final ScheduleOverview? overview;
  final Failure? failure;
  final TimeRestrictionActionStatus actionStatus;

  /// Outcome text of the last action, for one-off user feedback.
  final String? actionMessage;

  bool get isActionInProgress =>
      actionStatus == TimeRestrictionActionStatus.inProgress;

  @override
  List<Object?> get props => [
    status,
    overview,
    failure,
    actionStatus,
    actionMessage,
  ];
}
