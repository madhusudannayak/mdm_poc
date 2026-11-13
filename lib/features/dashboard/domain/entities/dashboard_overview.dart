import 'package:equatable/equatable.dart';

import '../../../../core/platform/models/device_status_models.dart';
import '../../../../core/platform/models/provisioning_status_model.dart';

/// Management summary shown at the top of the dashboard.
class DashboardOverview extends Equatable {
  const DashboardOverview({
    required this.managementMode,
    required this.provisioningState,
    required this.isDeviceOwner,
    required this.isDeviceAdminActive,
  });

  final ManagementMode managementMode;
  final ProvisioningState provisioningState;
  final bool isDeviceOwner;
  final bool isDeviceAdminActive;

  @override
  List<Object?> get props => [
    managementMode,
    provisioningState,
    isDeviceOwner,
    isDeviceAdminActive,
  ];
}
