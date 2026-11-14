import '../../../../core/utils/result.dart';
import '../repositories/application_repository.dart';

class AllowApplicationUseCase {
  const AllowApplicationUseCase(this._repository);

  final ApplicationRepository _repository;

  Future<Result<void>> call(String packageName) =>
      _repository.allowApplication(packageName);
}
