import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../../domain/usecases/get_dashboard_overview_use_case.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._getOverview) : super(const DashboardInitial()) {
    on<DashboardOverviewRequested>(_onRequested);
  }

  final GetDashboardOverviewUseCase _getOverview;

  Future<void> _onRequested(
    DashboardOverviewRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoading) return;
    emit(const DashboardLoading());
    emit(switch (await _getOverview()) {
      Success(:final value) => DashboardLoaded(value),
      FailureResult(:final failure) => DashboardLoadFailure(failure),
    });
  }
}
