import '../../../../core/utils/result.dart';
import '../entities/provisioning_status.dart';

abstract interface class ProvisioningRepository {
  /// Reads the real provisioning state from `DevicePolicyManager`.
  Future<Result<ProvisioningStatus>> getProvisioningStatus();
}
