part of 'applications_bloc.dart';

sealed class ApplicationsEvent extends Equatable {
  const ApplicationsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the inventory, replacing whatever is shown.
final class ApplicationsRequested extends ApplicationsEvent {
  const ApplicationsRequested();
}

/// Reloads the inventory while keeping the current list visible.
final class ApplicationsRefreshed extends ApplicationsEvent {
  const ApplicationsRefreshed();
}

final class ApplicationsSearchChanged extends ApplicationsEvent {
  const ApplicationsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ApplicationsTypeFilterChanged extends ApplicationsEvent {
  const ApplicationsTypeFilterChanged(this.filter);

  final ApplicationTypeFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class ApplicationsStatusFilterChanged extends ApplicationsEvent {
  const ApplicationsStatusFilterChanged(this.filter);

  final ApplicationStatusFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class ApplicationsSortChanged extends ApplicationsEvent {
  const ApplicationsSortChanged(this.sort);

  final ApplicationSort sort;

  @override
  List<Object?> get props => [sort];
}
