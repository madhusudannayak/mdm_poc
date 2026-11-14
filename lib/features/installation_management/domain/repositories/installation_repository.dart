import '../../../../core/utils/result.dart';
import '../entities/installation_restriction_status.dart';

abstract interface class InstallationRepository {
  Future<Result<InstallationRestrictionStatus>> getStatus();

  /// Blocks or allows ALL application installations.
  Future<Result<InstallationRestrictionStatus>> setInstallationsBlocked({
    required bool blocked,
  });

  /// Blocks or allows installation from unknown sources only.
  Future<Result<InstallationRestrictionStatus>> setUnknownSourcesBlocked({
    required bool blocked,
  });

  Future<Result<void>> setUninstallBlocked(
    String packageName, {
    required bool blocked,
  });
}
