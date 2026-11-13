import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// Effective installation restrictions read back from Android.
///
/// [installAppsRestricted] blocks every installation
/// (`DISALLOW_INSTALL_APPS`). [unknownSourcesRestricted] only blocks
/// sideloading from unknown sources and does not block store installations.
class InstallationRestrictionStatusModel extends Equatable {
  const InstallationRestrictionStatusModel({
    required this.installAppsRestricted,
    required this.unknownSourcesRestricted,
    this.unknownSourcesGloballyRestricted,
    this.uninstallBlockedPackages = const [],
  });

  factory InstallationRestrictionStatusModel.fromMap(Object? source) {
    final reader = MapReader(source, context: 'InstallationRestrictionStatus');
    return InstallationRestrictionStatusModel(
      installAppsRestricted: reader.boolean('installAppsRestricted'),
      unknownSourcesRestricted: reader.boolean('unknownSourcesRestricted'),
      unknownSourcesGloballyRestricted: reader.booleanOrNull(
        'unknownSourcesGloballyRestricted',
      ),
      uninstallBlockedPackages: reader.stringList('uninstallBlockedPackages'),
    );
  }

  final bool installAppsRestricted;
  final bool unknownSourcesRestricted;

  /// Null on Android versions without the global restriction (below API 29).
  final bool? unknownSourcesGloballyRestricted;
  final List<String> uninstallBlockedPackages;

  @override
  List<Object?> get props => [
    installAppsRestricted,
    unknownSourcesRestricted,
    unknownSourcesGloballyRestricted,
    uninstallBlockedPackages,
  ];
}
