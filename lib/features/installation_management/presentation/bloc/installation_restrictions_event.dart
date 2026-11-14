part of 'installation_restrictions_bloc.dart';

sealed class InstallationRestrictionsEvent extends Equatable {
  const InstallationRestrictionsEvent();

  @override
  List<Object?> get props => [];
}

final class InstallationRestrictionsRequested
    extends InstallationRestrictionsEvent {
  const InstallationRestrictionsRequested();
}

/// Dispatched only after the user confirmed the change.
final class InstallationBlockChangeConfirmed
    extends InstallationRestrictionsEvent {
  const InstallationBlockChangeConfirmed({required this.blocked});

  final bool blocked;

  @override
  List<Object?> get props => [blocked];
}

/// Dispatched only after the user confirmed the change.
final class UnknownSourcesBlockChangeConfirmed
    extends InstallationRestrictionsEvent {
  const UnknownSourcesBlockChangeConfirmed({required this.blocked});

  final bool blocked;

  @override
  List<Object?> get props => [blocked];
}

/// Dispatched only after the user confirmed the change.
final class UninstallBlockChangeConfirmed
    extends InstallationRestrictionsEvent {
  const UninstallBlockChangeConfirmed({
    required this.packageName,
    required this.blocked,
  });

  final String packageName;
  final bool blocked;

  @override
  List<Object?> get props => [packageName, blocked];
}
