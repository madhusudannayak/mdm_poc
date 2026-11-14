import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// A time window during which an application is allowed to run.
///
/// Times are minutes since local midnight (0..1439). When
/// [endMinuteOfDay] is not greater than [startMinuteOfDay] the window crosses
/// midnight. [daysOfWeek] uses ISO numbering: 1 = Monday .. 7 = Sunday, and
/// refers to the day on which the window starts.
class ApplicationScheduleModel extends Equatable {
  const ApplicationScheduleModel({
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

  factory ApplicationScheduleModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'ApplicationSchedule');
    return ApplicationScheduleModel(
      id: reader.integerOrNull('id'),
      packageName: reader.string('packageName'),
      startMinuteOfDay: reader.integer('startMinuteOfDay'),
      endMinuteOfDay: reader.integer('endMinuteOfDay'),
      daysOfWeek: reader.intList('daysOfWeek'),
      enabled: reader.boolean('enabled'),
      applicationName: reader.stringOrNull('applicationName'),
      isWithinAllowedWindow: reader.booleanOrNull('isWithinAllowedWindow'),
      isApplicationSuspended: reader.booleanOrNull('isApplicationSuspended'),
      nextTransitionAt: reader.integerOrNull('nextTransitionAt'),
    );
  }

  /// Null until the schedule has been persisted natively.
  final int? id;
  final String packageName;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final List<int> daysOfWeek;
  final bool enabled;

  // Live state reported by the device; never sent back to it.

  /// Null when the application is not installed.
  final String? applicationName;
  final bool? isWithinAllowedWindow;

  /// Real suspension state; null when the application is not installed.
  final bool? isApplicationSuspended;

  /// Epoch milliseconds of the next allowed/restricted change.
  final int? nextTransitionAt;

  bool get crossesMidnight => endMinuteOfDay <= startMinuteOfDay;

  Map<String, Object?> toMap() => {
    'id': id,
    'packageName': packageName,
    'startMinuteOfDay': startMinuteOfDay,
    'endMinuteOfDay': endMinuteOfDay,
    'daysOfWeek': daysOfWeek,
    'enabled': enabled,
  };

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

class ScheduleSyncFailureModel extends Equatable {
  const ScheduleSyncFailureModel({
    required this.packageName,
    required this.errorCode,
    required this.message,
  });

  factory ScheduleSyncFailureModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'ScheduleSyncFailure');
    return ScheduleSyncFailureModel(
      packageName: reader.string('packageName'),
      errorCode: reader.string('errorCode'),
      message: reader.string('message'),
    );
  }

  final String packageName;
  final String errorCode;
  final String message;

  @override
  List<Object?> get props => [packageName, errorCode, message];
}

/// Result of one native reconciliation pass over all schedules.
class ScheduleSyncReportModel extends Equatable {
  const ScheduleSyncReportModel({
    required this.isDeviceOwner,
    required this.evaluatedPackages,
    required this.changedPackages,
    required this.failures,
    required this.exactAlarmScheduled,
    this.nextTransitionAt,
  });

  factory ScheduleSyncReportModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'ScheduleSyncReport');
    return ScheduleSyncReportModel(
      isDeviceOwner: reader.boolean('isDeviceOwner'),
      evaluatedPackages: reader.integer('evaluatedPackages'),
      changedPackages: reader.stringList('changedPackages'),
      failures: MapReader.list(
        reader.raw('failures') ?? const <Object?>[],
        ScheduleSyncFailureModel.fromMap,
        context: 'ScheduleSyncReport.failures',
      ),
      exactAlarmScheduled: reader.boolean('exactAlarmScheduled'),
      nextTransitionAt: reader.integerOrNull('nextTransitionAt'),
    );
  }

  final bool isDeviceOwner;
  final int evaluatedPackages;

  /// Packages whose suspension state was changed by this pass.
  final List<String> changedPackages;
  final List<ScheduleSyncFailureModel> failures;

  /// False when the next transition uses an inexact alarm (or none).
  final bool exactAlarmScheduled;
  final int? nextTransitionAt;

  @override
  List<Object?> get props => [
    isDeviceOwner,
    evaluatedPackages,
    changedPackages,
    failures,
    exactAlarmScheduled,
    nextTransitionAt,
  ];
}
