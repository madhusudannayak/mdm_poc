import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/managed_application.dart';
import '../../domain/usecases/get_installed_applications_use_case.dart';

part 'applications_event.dart';
part 'applications_state.dart';

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  ApplicationsBloc(
    this._getInstalledApplications, {
    ApplicationStatusFilter initialStatusFilter = ApplicationStatusFilter.any,
  }) : super(ApplicationsState(statusFilter: initialStatusFilter)) {
    on<ApplicationsRequested>(_onRequested);
    on<ApplicationsRefreshed>(_onRefreshed);
    on<ApplicationsSearchChanged>(
      (event, emit) => emit(_withView(state.copyWith(query: event.query))),
    );
    on<ApplicationsTypeFilterChanged>(
      (event, emit) =>
          emit(_withView(state.copyWith(typeFilter: event.filter))),
    );
    on<ApplicationsStatusFilterChanged>(
      (event, emit) =>
          emit(_withView(state.copyWith(statusFilter: event.filter))),
    );
    on<ApplicationsSortChanged>(
      (event, emit) => emit(_withView(state.copyWith(sort: event.sort))),
    );
  }

  final GetInstalledApplicationsUseCase _getInstalledApplications;

  Future<void> _onRequested(
    ApplicationsRequested event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ApplicationsStatus.loading,
        applications: const [],
        visibleApplications: const [],
        failure: () => null,
        isRefreshing: false,
      ),
    );
    emit(_resolve(await _getInstalledApplications()));
  }

  Future<void> _onRefreshed(
    ApplicationsRefreshed event,
    Emitter<ApplicationsState> emit,
  ) async {
    if (state.isRefreshing || state.status == ApplicationsStatus.loading) {
      return;
    }
    emit(state.copyWith(isRefreshing: true));
    emit(_resolve(await _getInstalledApplications()));
  }

  /// A failed load never leaves a stale inventory on screen.
  ApplicationsState _resolve(Result<List<ManagedApplication>> result) =>
      switch (result) {
        Success(:final value) => _withView(
          state.copyWith(
            status: ApplicationsStatus.success,
            applications: value,
            failure: () => null,
            isRefreshing: false,
          ),
        ),
        FailureResult(:final failure) => state.copyWith(
          status: ApplicationsStatus.failure,
          applications: const [],
          visibleApplications: const [],
          failure: () => failure,
          isRefreshing: false,
        ),
      };

  static ApplicationsState _withView(ApplicationsState state) {
    final query = state.query.trim().toLowerCase();
    final visible = state.applications.where((application) {
      final matchesType = switch (state.typeFilter) {
        ApplicationTypeFilter.all => true,
        ApplicationTypeFilter.user => !application.isSystemApplication,
        ApplicationTypeFilter.system => application.isSystemApplication,
      };
      final matchesStatus = switch (state.statusFilter) {
        ApplicationStatusFilter.any => true,
        ApplicationStatusFilter.blocked => application.isBlocked,
        ApplicationStatusFilter.allowed => application.isAllowed,
      };
      final matchesQuery =
          query.isEmpty ||
          application.applicationName.toLowerCase().contains(query) ||
          application.packageName.toLowerCase().contains(query);
      return matchesType && matchesStatus && matchesQuery;
    }).toList()..sort(_comparator(state.sort));
    return state.copyWith(
      visibleApplications: List<ManagedApplication>.unmodifiable(visible),
    );
  }

  static Comparator<ManagedApplication> _comparator(ApplicationSort sort) {
    int byName(ManagedApplication a, ManagedApplication b) => a.applicationName
        .toLowerCase()
        .compareTo(b.applicationName.toLowerCase());
    return switch (sort) {
      ApplicationSort.name => byName,
      ApplicationSort.packageName => (a, b) => a.packageName.compareTo(
        b.packageName,
      ),
      ApplicationSort.blockedFirst => (a, b) {
        final rank = (b.isSuspended ? 1 : 0) - (a.isSuspended ? 1 : 0);
        return rank != 0 ? rank : byName(a, b);
      },
    };
  }
}
