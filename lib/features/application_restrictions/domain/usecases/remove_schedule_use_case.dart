import '../../../../core/utils/result.dart';
import '../repositories/schedule_repository.dart';

class RemoveScheduleUseCase {
  const RemoveScheduleUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Result<void>> call(int scheduleId) =>
      _repository.removeSchedule(scheduleId);
}
