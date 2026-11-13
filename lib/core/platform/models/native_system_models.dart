import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// What the native layer can do on this device right now.
class NativeCapabilitiesModel extends Equatable {
  const NativeCapabilitiesModel({
    required this.sdkInt,
    required this.implementedMethods,
    required this.capabilities,
  });

  factory NativeCapabilitiesModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'NativeCapabilities');
    return NativeCapabilitiesModel(
      sdkInt: reader.integer('sdkInt'),
      implementedMethods: reader.stringList('implementedMethods'),
      capabilities: reader.boolMap('capabilities'),
    );
  }

  final int sdkInt;

  /// Channel methods the installed native build actually handles.
  final List<String> implementedMethods;

  /// Capability name to availability, evaluated against the current
  /// privileges and Android version.
  final Map<String, bool> capabilities;

  bool implements(String method) => implementedMethods.contains(method);

  @override
  List<Object?> get props => [sdkInt, implementedMethods, capabilities];
}

/// One native operation audit record.
class NativeLogEntryModel extends Equatable {
  const NativeLogEntryModel({
    required this.operationId,
    required this.operationName,
    required this.requestTimestamp,
    required this.executionTimestamp,
    required this.success,
    required this.sdkVersion,
    this.packageName,
    this.errorCode,
    this.errorMessage,
  });

  factory NativeLogEntryModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'NativeLogEntry');
    return NativeLogEntryModel(
      operationId: reader.string('operationId'),
      operationName: reader.string('operationName'),
      packageName: reader.stringOrNull('packageName'),
      requestTimestamp: reader.integer('requestTimestamp'),
      executionTimestamp: reader.integer('executionTimestamp'),
      success: reader.boolean('success'),
      errorCode: reader.stringOrNull('errorCode'),
      errorMessage: reader.stringOrNull('errorMessage'),
      sdkVersion: reader.integer('sdkVersion'),
    );
  }

  final String operationId;
  final String operationName;
  final String? packageName;
  final int requestTimestamp;
  final int executionTimestamp;
  final bool success;
  final String? errorCode;
  final String? errorMessage;
  final int sdkVersion;

  @override
  List<Object?> get props => [
    operationId,
    operationName,
    packageName,
    requestTimestamp,
    executionTimestamp,
    success,
    errorCode,
    errorMessage,
    sdkVersion,
  ];
}

class NativePermissionModel extends Equatable {
  const NativePermissionModel({required this.name, required this.granted});

  factory NativePermissionModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'NativePermission');
    return NativePermissionModel(
      name: reader.string('name'),
      granted: reader.boolean('granted'),
    );
  }

  final String name;
  final bool granted;

  @override
  List<Object?> get props => [name, granted];
}

/// Manifest permissions requested by the app and whether each is granted,
/// plus special-access checks that are not ordinary permissions.
class NativePermissionsModel extends Equatable {
  const NativePermissionsModel({
    required this.permissions,
    required this.canScheduleExactAlarms,
  });

  factory NativePermissionsModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'NativePermissions');
    return NativePermissionsModel(
      permissions: MapReader.list(
        reader.raw('permissions') ?? const <Object?>[],
        NativePermissionModel.fromMap,
        context: 'NativePermissions.permissions',
      ),
      canScheduleExactAlarms: reader.boolean('canScheduleExactAlarms'),
    );
  }

  final List<NativePermissionModel> permissions;
  final bool canScheduleExactAlarms;

  @override
  List<Object?> get props => [permissions, canScheduleExactAlarms];
}
