import '../../../../core/platform/mdm_platform_interface.dart';
import '../../../../core/platform/models/provisioning_status_model.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/provisioning_status.dart';
import '../../domain/repositories/provisioning_repository.dart';

class ProvisioningRepositoryImpl implements ProvisioningRepository {
  const ProvisioningRepositoryImpl(this._platform);

  final MdmPlatformInterface _platform;

  @override
  Future<Result<ProvisioningStatus>> getProvisioningStatus() => Result.guard(
    () async => _toEntity(await _platform.getProvisioningStatus()),
  );

  static ProvisioningStatus _toEntity(ProvisioningStatusModel model) =>
      ProvisioningStatus(
        state: model.state,
        isDeviceOwner: model.isDeviceOwner,
        isProfileOwner: model.isProfileOwner,
        isDeviceAdminActive: model.isDeviceAdminActive,
        isDeviceAdminSupported: model.isDeviceAdminSupported,
        adminComponent: model.adminComponent,
        adbProvisioningCommand: model.adbProvisioningCommand,
        failureReason: model.failureReason,
        lastAdminEvent: model.lastAdminEvent,
        lastAdminEventAt: _toDateTime(model.lastAdminEventAt),
        provisioningCompletedAt: _toDateTime(model.provisioningCompletedAt),
      );

  static DateTime? _toDateTime(int? epochMillis) => epochMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(epochMillis);
}
