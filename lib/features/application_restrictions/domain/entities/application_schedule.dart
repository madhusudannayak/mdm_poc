import 'package:equatable/equatable.dart';

/// An allowed-time window for one application, with its live device state.
///
/// Times are minutes since local midnight. When [endMinuteOfDay] is not
/// after [startMinuteOfDay] the window runs overnight into the next day.
/// [daysOfWeek] uses ISO numbering (1 = Monday .. 7 = Sunday) and names the
/// day on which the window starts.
class ApplicationSchedule extends Equatable {
  const ApplicationSchedule({
    required this.packageName,
    required this.startMinuteOfDay,
    required this.endMinuteOfDay,
    required this.daysOfWeek,
    this.id,
    this.enabled = true,
    this.applicationName,
    this.isWithinAllowedWindow,
    this.isApplicationSuspended,
    this.nextTransitionAt,
  });

  final int? id;
  final String packageName;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final List<int> daysOfWeek;
  final bool enabled;

  /// Null when the application is not installed.
  final String? applicationName;
  final bool? isWithinAllowedWindow;
  final bool? isApplicationSuspended;
  final DateTime? nextTransitionAt;

  bool get crossesMidnight => endMinuteOfDay <= startMinuteOfDay;
  bool get isInstalled => isApplicationSuspended != null;
  String get displayName => applicationName ?? packageName;

  /// The device state disagrees with what this schedule requires right now.
  /// A blocklisted application is legitimately suspended inside its window,
  /// so only "should be suspended but is not" counts as not enforced.
  bool get isNotEnforced =>
      enabled &&
      isWithinAllowedWindow == false &&
      isApplicationSuspended == false;

  @override
  List<Object?> get props => [
    id,
    packageName,
    startMinuteOfDay,
    endMinuteOfDay,
    daysOfWeek,
    enabled,
    applicationName,
    isWithinAllowedWindow,
    isApplicationSuspended,
    nextTransitionAt,
  ];
}

/// Everything the time-restriction screen shows.
class ScheduleOverview extends Equatable {
  const ScheduleOverview({
    required this.schedules,
    required this.canScheduleExactAlarms,
  });

  final List<ApplicationSchedule> schedules;

  /// False when Android may deliver transitions late on this device.
  final bool canScheduleExactAlarms;

  @override
  List<Object?> get props => [schedules, canScheduleExactAlarms];
}

class ScheduleSyncFailure extends Equatable {
  const ScheduleSyncFailure({required this.packageName, required this.message});

  final String packageName;
  final String message;

  @override
  List<Object?> get props => [packageName, message];
}

/// Result of a manual synchronization.
class ScheduleSyncReport extends Equatable {
  const ScheduleSyncReport({
    required this.evaluatedPackages,
    required this.changedPackages,
    required this.failures,
  });

  final int evaluatedPackages;
  final List<String> changedPackages;
  final List<ScheduleSyncFailure> failures;

  String get summary {
    if (failures.isNotEmpty) {
      return 'Synchronization failed for ${failures.length} application(s): '
          '${failures.first.message}';
    }
    if (evaluatedPackages == 0) return 'No schedules to synchronize';
    return changedPackages.isEmpty
        ? 'All $evaluatedPackages scheduled application(s) already in the '
              'correct state'
        : 'Corrected ${changedPackages.length} of $evaluatedPackages '
              'scheduled application(s)';
  }

  @override
  List<Object?> get props => [evaluatedPackages, changedPackages, failures];
}
