part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads) the management overview from the device.
final class DashboardOverviewRequested extends DashboardEvent {
  const DashboardOverviewRequested();
}
