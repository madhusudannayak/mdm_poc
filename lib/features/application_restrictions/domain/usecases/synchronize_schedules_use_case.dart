import '../../../../core/utils/result.dart';
import '../entities/application_schedule.dart';
import '../repositories/schedule_repository.dart';

class SynchronizeSchedulesUseCase {
  const SynchronizeSchedulesUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Result<ScheduleSyncReport>> call() => _repository.synchronize();
}
