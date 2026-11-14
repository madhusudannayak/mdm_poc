import '../../../../core/utils/result.dart';
import '../entities/application_schedule.dart';
import '../repositories/schedule_repository.dart';

class SaveScheduleUseCase {
  const SaveScheduleUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Result<ApplicationSchedule>> call(ApplicationSchedule schedule) =>
      _repository.saveSchedule(schedule);
}
