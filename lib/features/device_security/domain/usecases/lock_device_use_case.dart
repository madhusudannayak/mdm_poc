import '../../../../core/utils/result.dart';
import '../repositories/device_security_repository.dart';

class LockDeviceUseCase {
  const LockDeviceUseCase(this._repository);

  final DeviceSecurityRepository _repository;

  Future<Result<void>> call() => _repository.lockDevice();
}
