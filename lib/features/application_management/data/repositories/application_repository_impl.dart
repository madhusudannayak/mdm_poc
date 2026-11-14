import '../../../../core/platform/mdm_platform_interface.dart';
import '../../../../core/platform/models/managed_application_model.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/managed_application.dart';
import '../../domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  const ApplicationRepositoryImpl(this._platform);

  final MdmPlatformInterface _platform;

  @override
  Future<Result<List<ManagedApplication>>> getInstalledApplications({
    bool includeIcons = true,
  }) => Result.guard(() async {
    final models = await _platform.getInstalledApplications(
      includeIcons: includeIcons,
    );
    return List<ManagedApplication>.unmodifiable(models.map(_toEntity));
  });

  @override
  Future<Result<ManagedApplication>> getApplicationDetails(
    String packageName,
  ) => Result.guard(
    () async => _toEntity(await _platform.getApplicationDetails(packageName)),
  );

  @override
  Future<Result<void>> blockApplication(String packageName) =>
      Result.guard(() => _platform.suspendApplication(packageName));

  @override
  Future<Result<void>> allowApplication(String packageName) =>
      Result.guard(() => _platform.unsuspendApplication(packageName));

  @override
  Future<Result<void>> setApplicationHidden(
    String packageName, {
    required bool hidden,
  }) => Result.guard(
    () => hidden
        ? _platform.setApplicationHidden(packageName)
        : _platform.setApplicationUnhidden(packageName),
  );

  static ManagedApplication _toEntity(ManagedApplicationModel model) =>
      ManagedApplication(
        packageName: model.packageName,
        applicationName: model.applicationName,
        versionName: model.versionName,
        versionCode: model.versionCode,
        isSystemApplication: model.isSystemApplication,
        isEnabled: model.isEnabled,
        isSuspended: model.isSuspended,
        isHidden: model.isHidden,
        isUninstallBlocked: model.isUninstallBlocked,
        installerPackageName: model.installerPackageName,
        policyStatus: model.policyStatus,
        iconPng: model.iconPng,
      );
}
