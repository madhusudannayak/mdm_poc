import '../../../../core/utils/result.dart';
import '../entities/managed_application.dart';
import '../repositories/application_repository.dart';

class GetInstalledApplicationsUseCase {
  const GetInstalledApplicationsUseCase(this._repository);

  final ApplicationRepository _repository;

  Future<Result<List<ManagedApplication>>> call({bool includeIcons = true}) =>
      _repository.getInstalledApplications(includeIcons: includeIcons);
}
