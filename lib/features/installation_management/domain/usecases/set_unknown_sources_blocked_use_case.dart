import '../../../../core/utils/result.dart';
import '../entities/installation_restriction_status.dart';
import '../repositories/installation_repository.dart';

class SetUnknownSourcesBlockedUseCase {
  const SetUnknownSourcesBlockedUseCase(this._repository);

  final InstallationRepository _repository;

  Future<Result<InstallationRestrictionStatus>> call({required bool blocked}) =>
      _repository.setUnknownSourcesBlocked(blocked: blocked);
}
