import '../../../../core/utils/result.dart';
import '../entities/application_schedule.dart';

abstract interface class ScheduleRepository {
  Future<Result<ScheduleOverview>> getOverview();

  /// Creates the schedule when it has no id, otherwise updates it.
  Future<Result<ApplicationSchedule>> saveSchedule(
    ApplicationSchedule schedule,
  );

  /// Deletes the schedule; the device restores the application's state.
  Future<Result<void>> removeSchedule(int scheduleId);

  Future<Result<void>> setScheduleEnabled(
    int scheduleId, {
    required bool enabled,
  });

  /// Re-evaluates all schedules on the device now.
  Future<Result<ScheduleSyncReport>> synchronize();
}
