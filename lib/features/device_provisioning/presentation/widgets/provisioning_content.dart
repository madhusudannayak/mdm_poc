import 'package:flutter/material.dart';

import '../../../../core/platform/models/provisioning_status_model.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/management_labels.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_card.dart';
import '../../domain/entities/provisioning_status.dart';
import 'provisioning_instructions.dart';

class ProvisioningContent extends StatelessWidget {
  const ProvisioningContent({required this.status, super.key});

  final ProvisioningStatus status;

  @override
  Widget build(BuildContext context) {
    final lastEventAt = status.lastAdminEventAt;
    final completedAt = status.provisioningCompletedAt;
    final failureReason = status.failureReason;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StatusCard(
          title: 'Provisioning status',
          status: status.state.label,
          tone: status.state.tone,
          icon: Icons.admin_panel_settings_outlined,
          description: status.state.explanation,
        ),
        if (failureReason != null) ...[
          const SizedBox(height: 12),
          SectionCard(title: 'Failure reason', children: [Text(failureReason)]),
        ],
        const SizedBox(height: 12),
        SectionCard(
          title: 'Details',
          children: [
            InfoRow(
              label: 'Device Owner',
              value: status.isDeviceOwner ? 'Yes' : 'No',
            ),
            InfoRow(
              label: 'Device administrator',
              value: status.isDeviceAdminActive ? 'Active' : 'Not active',
            ),
            InfoRow(
              label: 'Profile Owner',
              value: status.isProfileOwner ? 'Yes' : 'No',
            ),
            InfoRow(
              label: 'Device admin supported',
              value: status.isDeviceAdminSupported ? 'Yes' : 'No',
            ),
            InfoRow(
              label: 'Admin component',
              value: status.adminComponent,
              selectable: true,
            ),
            InfoRow(
              label: 'Last admin event',
              value: status.lastAdminEvent == null
                  ? 'None recorded'
                  : lastEventAt == null
                  ? status.lastAdminEvent
                  : '${status.lastAdminEvent} at '
                        '${DateTimeUtils.formatDateTime(lastEventAt)}',
            ),
            InfoRow(
              label: 'Provisioning completed',
              value: completedAt == null
                  ? 'Not recorded'
                  : DateTimeUtils.formatDateTime(completedAt),
            ),
          ],
        ),
        if (status.state != ProvisioningState.deviceOwnerActive) ...[
          const SizedBox(height: 12),
          ProvisioningInstructions(adbCommand: status.adbProvisioningCommand),
        ],
      ],
    );
  }
}
