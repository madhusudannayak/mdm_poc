import '../../../../core/utils/result.dart';
import '../entities/device_security_status.dart';

abstract interface class DeviceSecurityRepository {
  Future<Result<DeviceSecurityStatus>> getStatus();

  /// Locks the physical device now.
  Future<Result<void>> lockDevice();

  /// Factory resets the device. Only call after explicit user confirmation.
  /// The device may begin wiping before any result is delivered.
  Future<Result<void>> factoryReset();
}
