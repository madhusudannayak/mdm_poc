part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.overview);

  final DashboardOverview overview;

  @override
  List<Object?> get props => [overview];
}

final class DashboardLoadFailure extends DashboardState {
  const DashboardLoadFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
