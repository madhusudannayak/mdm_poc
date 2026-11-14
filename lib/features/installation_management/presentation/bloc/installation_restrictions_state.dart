part of 'installation_restrictions_bloc.dart';

enum InstallationActionStatus { idle, inProgress, success, failure }

final class InstallationRestrictionsState extends Equatable {
  const InstallationRestrictionsState({
    this.restrictions,
    this.failure,
    this.actionStatus = InstallationActionStatus.idle,
    this.actionMessage,
  });

  /// Null until loaded, and after a failed load.
  final InstallationRestrictionStatus? restrictions;
  final Failure? failure;
  final InstallationActionStatus actionStatus;

  /// Outcome text of the last action, for one-off user feedback.
  final String? actionMessage;

  bool get isActionInProgress =>
      actionStatus == InstallationActionStatus.inProgress;

  @override
  List<Object?> get props => [
    restrictions,
    failure,
    actionStatus,
    actionMessage,
  ];
}
