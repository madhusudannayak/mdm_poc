import '../../../../core/platform/mdm_platform_interface.dart';
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
    return DashboardOverview(
      managementMode: management.managementMode,
      provisioningState: provisioning.state,
      isDeviceOwner: management.isDeviceOwner,
      isDeviceAdminActive: management.isDeviceAdminActive,
    );
  });
}
