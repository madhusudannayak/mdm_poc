part of 'application_details_bloc.dart';

enum ApplicationDetailsStatus { loading, success, failure }

enum ApplicationActionStatus { idle, inProgress, success, failure }

final class ApplicationDetailsState extends Equatable {
  const ApplicationDetailsState({
    this.status = ApplicationDetailsStatus.loading,
    this.application,
    this.failure,
    this.actionStatus = ApplicationActionStatus.idle,
    this.actionMessage,
  });

  final ApplicationDetailsStatus status;
  final ManagedApplication? application;

  /// Why the details could not be loaded.
  final Failure? failure;
  final ApplicationActionStatus actionStatus;

  /// Outcome text of the last action, for one-off user feedback.
  final String? actionMessage;

  bool get isActionInProgress =>
      actionStatus == ApplicationActionStatus.inProgress;

  @override
  List<Object?> get props => [
    status,
    application,
    failure,
    actionStatus,
    actionMessage,
  ];
}
