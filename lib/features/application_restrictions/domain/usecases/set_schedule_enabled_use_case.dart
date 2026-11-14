import '../../../../core/utils/result.dart';
import '../repositories/schedule_repository.dart';

class SetScheduleEnabledUseCase {
  const SetScheduleEnabledUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Result<void>> call(int scheduleId, {required bool enabled}) =>
      _repository.setScheduleEnabled(scheduleId, enabled: enabled);
}
