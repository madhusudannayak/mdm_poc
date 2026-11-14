part of 'applications_bloc.dart';

enum ApplicationsStatus { initial, loading, success, failure }

enum ApplicationTypeFilter { all, user, system }

enum ApplicationStatusFilter { any, blocked, allowed }

enum ApplicationSort { name, packageName, blockedFirst }

final class ApplicationsState extends Equatable {
  const ApplicationsState({
    this.status = ApplicationsStatus.initial,
    this.applications = const [],
    this.visibleApplications = const [],
    this.query = '',
    this.typeFilter = ApplicationTypeFilter.all,
    this.statusFilter = ApplicationStatusFilter.any,
    this.sort = ApplicationSort.name,
    this.failure,
    this.isRefreshing = false,
  });

  final ApplicationsStatus status;

  /// Full inventory as returned by the device.
  final List<ManagedApplication> applications;

  /// [applications] after search, filters and sorting.
  final List<ManagedApplication> visibleApplications;
  final String query;
  final ApplicationTypeFilter typeFilter;
  final ApplicationStatusFilter statusFilter;
  final ApplicationSort sort;
  final Failure? failure;
  final bool isRefreshing;

  ApplicationsState copyWith({
    ApplicationsStatus? status,
    List<ManagedApplication>? applications,
    List<ManagedApplication>? visibleApplications,
    String? query,
    ApplicationTypeFilter? typeFilter,
    ApplicationStatusFilter? statusFilter,
    ApplicationSort? sort,
    Failure? Function()? failure,
    bool? isRefreshing,
  }) => ApplicationsState(
    status: status ?? this.status,
    applications: applications ?? this.applications,
    visibleApplications: visibleApplications ?? this.visibleApplications,
    query: query ?? this.query,
    typeFilter: typeFilter ?? this.typeFilter,
    statusFilter: statusFilter ?? this.statusFilter,
    sort: sort ?? this.sort,
    failure: failure == null ? this.failure : failure(),
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [
    status,
    applications,
    visibleApplications,
    query,
    typeFilter,
    statusFilter,
    sort,
    failure,
    isRefreshing,
  ];
}
