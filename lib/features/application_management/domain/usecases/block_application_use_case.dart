import '../../../../core/utils/result.dart';
import '../repositories/application_repository.dart';

class BlockApplicationUseCase {
  const BlockApplicationUseCase(this._repository);

  final ApplicationRepository _repository;

  Future<Result<void>> call(String packageName) =>
      _repository.blockApplication(packageName);
}
