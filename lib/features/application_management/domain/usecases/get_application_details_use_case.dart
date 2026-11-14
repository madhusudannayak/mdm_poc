import '../../../../core/utils/result.dart';
import '../entities/managed_application.dart';
import '../repositories/application_repository.dart';

class GetApplicationDetailsUseCase {
  const GetApplicationDetailsUseCase(this._repository);

  final ApplicationRepository _repository;

  Future<Result<ManagedApplication>> call(String packageName) =>
      _repository.getApplicationDetails(packageName);
}
