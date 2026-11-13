import '../../../../core/utils/result.dart';
import '../entities/provisioning_status.dart';
import '../repositories/provisioning_repository.dart';

class GetProvisioningStatusUseCase {
  const GetProvisioningStatusUseCase(this._repository);

  final ProvisioningRepository _repository;

  Future<Result<ProvisioningStatus>> call() =>
      _repository.getProvisioningStatus();
}
