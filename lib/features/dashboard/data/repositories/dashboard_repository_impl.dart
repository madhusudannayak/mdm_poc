import '../../../../core/platform/mdm_platform_interface.dart';
import '../../../../core/platform/models/managed_application_model.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._platform);

  final MdmPlatformInterface _platform;

  @override
  Future<Result<DashboardOverview>> getOverview() => Result.guard(() async {
    final management = await _platform.getDeviceManagementStatus();
    final provisioning = await _platform.getProvisioningStatus();
    // Counts only: icons are skipped to keep the dashboard load light.
    final applications = await _platform.getInstalledApplications(
      includeIcons: false,
    );
    final schedules = await _platform.getApplicationSchedules();
    final installation = await _platform.getInstallationRestrictionStatus();
    int countWith(ApplicationPolicyStatus status) =>
        applications.where((app) => app.policyStatus == status).length;
    return DashboardOverview(
      managementMode: management.managementMode,
      provisioningState: provisioning.state,
      isDeviceOwner: management.isDeviceOwner,
      isDeviceAdminActive: management.isDeviceAdminActive,
      installedApplicationCount: applications.length,
      blockedApplicationCount: countWith(ApplicationPolicyStatus.blocked),
      allowedApplicationCount: countWith(ApplicationPolicyStatus.allowed),
      activeScheduleCount: schedules.where((s) => s.enabled).length,
      installationsBlocked: installation.installAppsRestricted,
      unknownSourcesBlocked: installation.unknownSourcesRestricted,
    );
  });
}
