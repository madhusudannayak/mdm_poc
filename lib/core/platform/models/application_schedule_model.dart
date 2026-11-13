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
    );
  }

  /// Null until the schedule has been persisted natively.
  final int? id;
  final String packageName;
  final int startMinuteOfDay;
  final int endMinuteOfDay;
  final List<int> daysOfWeek;
  final bool enabled;

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
  ];
}
