part of 'application_details_bloc.dart';

sealed class ApplicationDetailsEvent extends Equatable {
  const ApplicationDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class ApplicationDetailsRequested extends ApplicationDetailsEvent {
  const ApplicationDetailsRequested();
}

/// Dispatched only after the user confirmed blocking the application.
final class ApplicationBlockConfirmed extends ApplicationDetailsEvent {
  const ApplicationBlockConfirmed();
}

/// Dispatched only after the user confirmed allowing the application.
final class ApplicationAllowConfirmed extends ApplicationDetailsEvent {
  const ApplicationAllowConfirmed();
}

/// Dispatched only after the user confirmed hiding or unhiding.
final class ApplicationHiddenChangeConfirmed extends ApplicationDetailsEvent {
  const ApplicationHiddenChangeConfirmed({required this.hidden});

  final bool hidden;

  @override
  List<Object?> get props => [hidden];
}
