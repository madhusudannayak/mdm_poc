import '../../../../core/utils/result.dart';
import '../entities/installation_restriction_status.dart';
import '../repositories/installation_repository.dart';

class GetInstallationRestrictionStatusUseCase {
  const GetInstallationRestrictionStatusUseCase(this._repository);

  final InstallationRepository _repository;

  Future<Result<InstallationRestrictionStatus>> call() =>
      _repository.getStatus();
}
