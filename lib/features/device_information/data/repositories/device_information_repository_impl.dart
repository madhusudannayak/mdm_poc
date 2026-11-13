import '../../../../core/platform/mdm_platform_interface.dart';
import '../../../../core/platform/models/device_information_model.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/device_information.dart';
import '../../domain/repositories/device_information_repository.dart';

class DeviceInformationRepositoryImpl implements DeviceInformationRepository {
  const DeviceInformationRepositoryImpl(this._platform);

  final MdmPlatformInterface _platform;

  @override
  Future<Result<DeviceInformation>> getDeviceInformation() =>
      Result.guard(() async => _toEntity(await _platform.getDeviceInfo()));

  static DeviceInformation _toEntity(DeviceInformationModel model) =>
      DeviceInformation(
        manufacturer: model.manufacturer,
        model: model.model,
        brand: model.brand,
        deviceName: model.deviceName,
        androidVersion: model.androidVersion,
        sdkVersion: model.sdkVersion,
        securityPatchLevel: model.securityPatchLevel,
        buildFingerprint: model.buildFingerprint,
        appVersionName: model.appVersionName,
        appVersionCode: model.appVersionCode,
        isDeviceOwner: model.isDeviceOwner,
        isDeviceAdminActive: model.isDeviceAdminActive,
        managementMode: model.managementMode,
        batteryPercentage: model.batteryPercentage,
      );
}
