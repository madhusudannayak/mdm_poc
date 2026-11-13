import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// A versioned organizational policy applied through the native policy
/// engine. Time-based schedules are managed separately through the
/// scheduling methods.
class DevicePolicyModel extends Equatable {
  const DevicePolicyModel({
    required this.id,
    required this.name,
    required this.version,
    this.allowedPackages = const [],
    this.blockedPackages = const [],
    this.uninstallBlockedPackages = const [],
    this.installationsBlocked = false,
    this.unknownSourcesBlocked = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DevicePolicyModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'DevicePolicy');
    return DevicePolicyModel(
      id: reader.string('id'),
      name: reader.string('name'),
      version: reader.integer('version'),
      allowedPackages: reader.stringList('allowedPackages'),
      blockedPackages: reader.stringList('blockedPackages'),
      uninstallBlockedPackages: reader.stringList('uninstallBlockedPackages'),
      installationsBlocked: reader.boolean('installationsBlocked'),
      unknownSourcesBlocked: reader.boolean('unknownSourcesBlocked'),
      createdAt: reader.integerOrNull('createdAt'),
      updatedAt: reader.integerOrNull('updatedAt'),
    );
  }

  final String id;
  final String name;
  final int version;
  final List<String> allowedPackages;
  final List<String> blockedPackages;
  final List<String> uninstallBlockedPackages;
  final bool installationsBlocked;
  final bool unknownSourcesBlocked;

  /// Epoch milliseconds, assigned natively when the policy is stored.
  final int? createdAt;
  final int? updatedAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'version': version,
    'allowedPackages': allowedPackages,
    'blockedPackages': blockedPackages,
    'uninstallBlockedPackages': uninstallBlockedPackages,
    'installationsBlocked': installationsBlocked,
    'unknownSourcesBlocked': unknownSourcesBlocked,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    version,
    allowedPackages,
    blockedPackages,
    uninstallBlockedPackages,
    installationsBlocked,
    unknownSourcesBlocked,
    createdAt,
    updatedAt,
  ];
}
