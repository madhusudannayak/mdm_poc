import '../../../../core/utils/result.dart';
import '../entities/dashboard_overview.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardOverviewUseCase {
  const GetDashboardOverviewUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Result<DashboardOverview>> call() => _repository.getOverview();
}
