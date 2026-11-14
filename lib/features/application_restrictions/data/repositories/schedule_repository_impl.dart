import '../../../../core/platform/mdm_platform_interface.dart';
import '../../../../core/platform/models/application_schedule_model.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/application_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl(this._platform);

  final MdmPlatformInterface _platform;

  @override
  Future<Result<ScheduleOverview>> getOverview() => Result.guard(() async {
    final schedules = await _platform.getApplicationSchedules();
    final permissions = await _platform.checkNativePermissions();
    return ScheduleOverview(
      schedules: List<ApplicationSchedule>.unmodifiable(
        schedules.map(_toEntity),
      ),
      canScheduleExactAlarms: permissions.canScheduleExactAlarms,
    );
  });

  @override
  Future<Result<ApplicationSchedule>> saveSchedule(
    ApplicationSchedule schedule,
  ) => Result.guard(() async {
    final model = ApplicationScheduleModel(
      id: schedule.id,
      packageName: schedule.packageName,
      startMinuteOfDay: schedule.startMinuteOfDay,
      endMinuteOfDay: schedule.endMinuteOfDay,
      daysOfWeek: schedule.daysOfWeek,
      enabled: schedule.enabled,
    );
    final saved = schedule.id == null
        ? await _platform.saveApplicationSchedule(model)
        : await _platform.updateApplicationSchedule(model);
    return _toEntity(saved);
  });

  @override
  Future<Result<void>> removeSchedule(int scheduleId) =>
      Result.guard(() => _platform.removeApplicationSchedule(scheduleId));

  @override
  Future<Result<void>> setScheduleEnabled(
    int scheduleId, {
    required bool enabled,
  }) => Result.guard(
    () => enabled
        ? _platform.enableApplicationSchedule(scheduleId)
        : _platform.disableApplicationSchedule(scheduleId),
  );

  @override
  Future<Result<ScheduleSyncReport>> synchronize() => Result.guard(() async {
    final report = await _platform.synchronizeApplicationSchedules();
    return ScheduleSyncReport(
      evaluatedPackages: report.evaluatedPackages,
      changedPackages: report.changedPackages,
      failures: [
        for (final failure in report.failures)
          ScheduleSyncFailure(
            packageName: failure.packageName,
            message: failure.message,
          ),
      ],
    );
  });

  static ApplicationSchedule _toEntity(ApplicationScheduleModel model) {
    final nextTransitionAt = model.nextTransitionAt;
    return ApplicationSchedule(
      id: model.id,
      packageName: model.packageName,
      startMinuteOfDay: model.startMinuteOfDay,
      endMinuteOfDay: model.endMinuteOfDay,
      daysOfWeek: model.daysOfWeek,
      enabled: model.enabled,
      applicationName: model.applicationName,
      isWithinAllowedWindow: model.isWithinAllowedWindow,
      isApplicationSuspended: model.isApplicationSuspended,
      nextTransitionAt: nextTransitionAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(nextTransitionAt),
    );
  }
}
