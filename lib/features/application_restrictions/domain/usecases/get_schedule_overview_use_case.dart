import '../../../../core/utils/result.dart';
import '../entities/application_schedule.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleOverviewUseCase {
  const GetScheduleOverviewUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Result<ScheduleOverview>> call() => _repository.getOverview();
}
