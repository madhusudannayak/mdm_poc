import '../../../../core/utils/result.dart';
import '../entities/managed_application.dart';

abstract interface class ApplicationRepository {
  Future<Result<List<ManagedApplication>>> getInstalledApplications({
    bool includeIcons = true,
  });

  Future<Result<ManagedApplication>> getApplicationDetails(String packageName);

  /// Suspends the application and records it on the blocklist.
  Future<Result<void>> blockApplication(String packageName);

  /// Unsuspends the application and records it on the allowlist.
  Future<Result<void>> allowApplication(String packageName);

  /// Hides or unhides the application. Hiding is not suspension.
  Future<Result<void>> setApplicationHidden(
    String packageName, {
    required bool hidden,
  });
}
