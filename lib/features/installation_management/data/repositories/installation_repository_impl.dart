import '../../../../core/platform/mdm_platform_interface.dart';
import '../../../../core/platform/models/installation_restriction_status_model.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/installation_restriction_status.dart';
import '../../domain/repositories/installation_repository.dart';

class InstallationRepositoryImpl implements InstallationRepository {
  const InstallationRepositoryImpl(this._platform);

  final MdmPlatformInterface _platform;

  @override
  Future<Result<InstallationRestrictionStatus>> getStatus() => Result.guard(
    () async => _toEntity(await _platform.getInstallationRestrictionStatus()),
  );

  @override
  Future<Result<InstallationRestrictionStatus>> setInstallationsBlocked({
    required bool blocked,
  }) => Result.guard(
    () async => _toEntity(
      await _platform.setApplicationInstallationRestriction(enabled: blocked),
    ),
  );

  @override
  Future<Result<InstallationRestrictionStatus>> setUnknownSourcesBlocked({
    required bool blocked,
  }) => Result.guard(
    () async => _toEntity(
      await _platform.setUnknownSourcesRestriction(enabled: blocked),
    ),
  );

  @override
  Future<Result<void>> setUninstallBlocked(
    String packageName, {
    required bool blocked,
  }) => Result.guard(
    () =>
        _platform.setApplicationUninstallBlocked(packageName, blocked: blocked),
  );

  static InstallationRestrictionStatus _toEntity(
    InstallationRestrictionStatusModel model,
  ) => InstallationRestrictionStatus(
    installationsBlocked: model.installAppsRestricted,
    unknownSourcesBlocked: model.unknownSourcesRestricted,
    unknownSourcesBlockedGlobally: model.unknownSourcesGloballyRestricted,
    uninstallBlockedPackages: model.uninstallBlockedPackages,
  );
}
