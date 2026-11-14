import '../../../../core/utils/result.dart';
import '../repositories/device_security_repository.dart';

/// Must only be invoked from an explicit, confirmed user action.
class FactoryResetDeviceUseCase {
  const FactoryResetDeviceUseCase(this._repository);

  final DeviceSecurityRepository _repository;

  Future<Result<void>> call() => _repository.factoryReset();
}
