import 'package:equatable/equatable.dart';

/// Effective installation restrictions as reported by Android.
///
/// [installationsBlocked] blocks every installation. [unknownSourcesBlocked]
/// only blocks sideloading; store installations still work.
class InstallationRestrictionStatus extends Equatable {
  const InstallationRestrictionStatus({
    required this.installationsBlocked,
    required this.unknownSourcesBlocked,
    required this.uninstallBlockedPackages,
    this.unknownSourcesBlockedGlobally,
  });

  final bool installationsBlocked;
  final bool unknownSourcesBlocked;

  /// Null on Android versions without the device-wide restriction.
  final bool? unknownSourcesBlockedGlobally;
  final List<String> uninstallBlockedPackages;

  @override
  List<Object?> get props => [
    installationsBlocked,
    unknownSourcesBlocked,
    unknownSourcesBlockedGlobally,
    uninstallBlockedPackages,
  ];
}
