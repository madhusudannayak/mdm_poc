import '../../../../core/utils/result.dart';
import '../entities/device_security_status.dart';
import '../repositories/device_security_repository.dart';

class GetDeviceSecurityStatusUseCase {
  const GetDeviceSecurityStatusUseCase(this._repository);

  final DeviceSecurityRepository _repository;

  Future<Result<DeviceSecurityStatus>> call() => _repository.getStatus();
}
