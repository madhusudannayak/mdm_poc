import '../../../../core/platform/mdm_platform_interface.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/device_security_status.dart';
import '../../domain/repositories/device_security_repository.dart';

class DeviceSecurityRepositoryImpl implements DeviceSecurityRepository {
  const DeviceSecurityRepositoryImpl(this._platform);

  final MdmPlatformInterface _platform;

  @override
  Future<Result<DeviceSecurityStatus>> getStatus() => Result.guard(() async {
    final capabilities = (await _platform.getNativeCapabilities()).capabilities;
    bool has(String key) => capabilities[key] ?? false;
    return DeviceSecurityStatus(
      isDeviceOwner: has('deviceOwner'),
      isDeviceAdminActive: has('deviceAdminActive'),
      canLockDevice: has('deviceLock'),
      canWipeDevice: has('deviceWipe'),
      isLockScreenSecured: has('lockScreenSecured'),
    );
  });

  @override
  Future<Result<void>> lockDevice() => Result.guard(_platform.lockDevice);

  @override
  Future<Result<void>> factoryReset() =>
      Result.guard(() => _platform.wipeDevice(confirmed: true));
}
