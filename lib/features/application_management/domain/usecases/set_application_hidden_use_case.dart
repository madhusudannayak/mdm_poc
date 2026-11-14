import '../../../../core/utils/result.dart';
import '../repositories/application_repository.dart';

class SetApplicationHiddenUseCase {
  const SetApplicationHiddenUseCase(this._repository);

  final ApplicationRepository _repository;

  Future<Result<void>> call(String packageName, {required bool hidden}) =>
      _repository.setApplicationHidden(packageName, hidden: hidden);
}
