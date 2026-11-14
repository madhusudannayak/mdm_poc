import '../../../../core/utils/result.dart';
import '../repositories/installation_repository.dart';

class SetUninstallBlockedUseCase {
  const SetUninstallBlockedUseCase(this._repository);

  final InstallationRepository _repository;

  Future<Result<void>> call(String packageName, {required bool blocked}) =>
      _repository.setUninstallBlocked(packageName, blocked: blocked);
}
