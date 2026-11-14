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
    required this.installedApplicationCount,
    required this.blockedApplicationCount,
    required this.allowedApplicationCount,
    required this.activeScheduleCount,
    required this.installationsBlocked,
    required this.unknownSourcesBlocked,
  });

  final ManagementMode managementMode;
  final ProvisioningState provisioningState;
  final bool isDeviceOwner;
  final bool isDeviceAdminActive;
  final int installedApplicationCount;

  /// Applications on the organization's blocklist.
  final int blockedApplicationCount;

  /// Applications on the organization's allowlist.
  final int allowedApplicationCount;

  /// Enabled time-based restriction schedules.
  final int activeScheduleCount;

  /// All installations are blocked.
  final bool installationsBlocked;

  /// Sideloading is blocked; store installations are not.
  final bool unknownSourcesBlocked;

  @override
  List<Object?> get props => [
    managementMode,
    provisioningState,
    isDeviceOwner,
    isDeviceAdminActive,
    installedApplicationCount,
    blockedApplicationCount,
    allowedApplicationCount,
    activeScheduleCount,
    installationsBlocked,
    unknownSourcesBlocked,
  ];
}
