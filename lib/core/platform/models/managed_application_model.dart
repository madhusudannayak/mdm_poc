import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// The organization's recorded decision for a package.
enum ApplicationPolicyStatus {
  /// On the blocklist: explicitly prohibited, enforced by suspension.
  blocked('BLOCKED'),

  /// On the allowlist: explicitly permitted.
  allowed('ALLOWED'),

  /// No decision recorded.
  unspecified('UNSPECIFIED');

  const ApplicationPolicyStatus(this.wireValue);

  final String wireValue;

  static ApplicationPolicyStatus fromWire(String? value) => values.firstWhere(
    (status) => status.wireValue == value,
    orElse: () => ApplicationPolicyStatus.unspecified,
  );
}

/// An installed application as reported by Android `PackageManager`, together
/// with the management state applied to it.
class ManagedApplicationModel extends Equatable {
  const ManagedApplicationModel({
    required this.packageName,
    required this.applicationName,
    required this.isSystemApplication,
    required this.isEnabled,
    required this.isSuspended,
    required this.isHidden,
    required this.isUninstallBlocked,
    this.policyStatus = ApplicationPolicyStatus.unspecified,
    this.versionName,
    this.versionCode,
    this.installerPackageName,
    this.iconPng,
  });

  factory ManagedApplicationModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'ManagedApplication');
    final icon = reader.raw('iconPng');
    return ManagedApplicationModel(
      packageName: reader.string('packageName'),
      applicationName: reader.string('applicationName'),
      versionName: reader.stringOrNull('versionName'),
      versionCode: reader.integerOrNull('versionCode'),
      isSystemApplication: reader.boolean('isSystemApplication'),
      isEnabled: reader.boolean('isEnabled'),
      isSuspended: reader.boolean('isSuspended'),
      isHidden: reader.boolean('isHidden'),
      isUninstallBlocked: reader.boolean('isUninstallBlocked'),
      installerPackageName: reader.stringOrNull('installerPackageName'),
      policyStatus: ApplicationPolicyStatus.fromWire(
        reader.stringOrNull('policyStatus'),
      ),
      iconPng: icon is Uint8List ? icon : null,
    );
  }

  final String packageName;
  final String applicationName;
  final String? versionName;
  final int? versionCode;
  final bool isSystemApplication;
  final bool isEnabled;
  final bool isSuspended;
  final bool isHidden;
  final bool isUninstallBlocked;
  final String? installerPackageName;
  final ApplicationPolicyStatus policyStatus;
  final Uint8List? iconPng;

  @override
  List<Object?> get props => [
    packageName,
    applicationName,
    versionName,
    versionCode,
    isSystemApplication,
    isEnabled,
    isSuspended,
    isHidden,
    isUninstallBlocked,
    installerPackageName,
    policyStatus,
    iconPng,
  ];
}
