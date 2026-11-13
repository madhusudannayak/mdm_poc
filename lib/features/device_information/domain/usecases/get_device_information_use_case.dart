import '../../../../core/utils/result.dart';
import '../entities/device_information.dart';
import '../repositories/device_information_repository.dart';

class GetDeviceInformationUseCase {
  const GetDeviceInformationUseCase(this._repository);

  final DeviceInformationRepository _repository;

  Future<Result<DeviceInformation>> call() =>
      _repository.getDeviceInformation();
}
