import '../../../../core/utils/result.dart';
import '../entities/device_information.dart';

abstract interface class DeviceInformationRepository {
  /// Reads current device details from native Android APIs.
  Future<Result<DeviceInformation>> getDeviceInformation();
}
