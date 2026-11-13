import '../platform/models/device_status_models.dart';
import '../platform/models/provisioning_status_model.dart';
import 'status_card.dart';

/// Display text and tone for [ManagementMode].
extension ManagementModePresentation on ManagementMode {
  String get label => switch (this) {
    ManagementMode.fullyManaged => 'Fully managed (Device Owner)',
    ManagementMode.profileOwner => 'Profile Owner',
    ManagementMode.deviceAdmin => 'Device administrator only',
    ManagementMode.unmanaged => 'Not managed',
  };

  StatusTone get tone => switch (this) {
    ManagementMode.fullyManaged => StatusTone.positive,
    ManagementMode.profileOwner => StatusTone.warning,
    ManagementMode.deviceAdmin => StatusTone.warning,
    ManagementMode.unmanaged => StatusTone.neutral,
  };
}

/// Display text and tone for [ProvisioningState].
extension ProvisioningStatePresentation on ProvisioningState {
  String get label => switch (this) {
    ProvisioningState.notProvisioned => 'Not provisioned',
    ProvisioningState.deviceAdminActive => 'Device administrator active',
    ProvisioningState.deviceOwnerActive => 'Device Owner active',
    ProvisioningState.provisioningFailed => 'Provisioning failed',
  };

  StatusTone get tone => switch (this) {
    ProvisioningState.notProvisioned => StatusTone.neutral,
    ProvisioningState.deviceAdminActive => StatusTone.warning,
    ProvisioningState.deviceOwnerActive => StatusTone.positive,
    ProvisioningState.provisioningFailed => StatusTone.negative,
  };

  String get explanation => switch (this) {
    ProvisioningState.notProvisioned =>
      'This app holds no management role. Device management operations '
          'are unavailable until it is provisioned as Device Owner.',
    ProvisioningState.deviceAdminActive =>
      'The app is an active device administrator but is not Device Owner. '
          'Device administrator alone cannot suspend apps, restrict '
          'installation or factory reset the device.',
    ProvisioningState.deviceOwnerActive =>
      'This app is Device Owner of a fully managed device. All device '
          'management operations are available.',
    ProvisioningState.provisioningFailed =>
      'Provisioning did not result in Device Owner privileges. See the '
          'reason below.',
  };
}
