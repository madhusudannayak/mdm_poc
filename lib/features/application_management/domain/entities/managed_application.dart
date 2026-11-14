import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../../core/platform/models/managed_application_model.dart';

/// An installed application and the management state Android reports for it.
///
/// [isSuspended] is the real device state; [policyStatus] is the recorded
/// organizational decision. They can differ, for example when a blocked app
/// was reinstalled, and both are shown.
class ManagedApplication extends Equatable {
  const ManagedApplication({
    required this.packageName,
    required this.applicationName,
    required this.isSystemApplication,
    required this.isEnabled,
    required this.isSuspended,
    required this.isHidden,
    required this.isUninstallBlocked,
    required this.policyStatus,
    this.versionName,
    this.versionCode,
    this.installerPackageName,
    this.iconPng,
  });

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

  bool get isBlocked => policyStatus == ApplicationPolicyStatus.blocked;
  bool get isAllowed => policyStatus == ApplicationPolicyStatus.allowed;

  /// Icon bytes are excluded: they are large and never change independently
  /// of the package version.
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
  ];
}
