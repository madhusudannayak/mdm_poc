import 'package:equatable/equatable.dart';

import '../../../../core/platform/models/provisioning_status_model.dart';

/// Provisioning state of this app plus the facts it was derived from.
class ProvisioningStatus extends Equatable {
  const ProvisioningStatus({
    required this.state,
    required this.isDeviceOwner,
    required this.isProfileOwner,
    required this.isDeviceAdminActive,
    required this.isDeviceAdminSupported,
    required this.adminComponent,
    required this.adbProvisioningCommand,
    this.failureReason,
    this.lastAdminEvent,
    this.lastAdminEventAt,
    this.provisioningCompletedAt,
  });

  final ProvisioningState state;
  final bool isDeviceOwner;
  final bool isProfileOwner;
  final bool isDeviceAdminActive;
  final bool isDeviceAdminSupported;
  final String adminComponent;
  final String adbProvisioningCommand;
  final String? failureReason;
  final String? lastAdminEvent;
  final DateTime? lastAdminEventAt;
  final DateTime? provisioningCompletedAt;

  @override
  List<Object?> get props => [
    state,
    isDeviceOwner,
    isProfileOwner,
    isDeviceAdminActive,
    isDeviceAdminSupported,
    adminComponent,
    adbProvisioningCommand,
    failureReason,
    lastAdminEvent,
    lastAdminEventAt,
    provisioningCompletedAt,
  ];
}
