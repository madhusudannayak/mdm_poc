import 'package:flutter/material.dart';

import '../../../../core/platform/models/managed_application_model.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/managed_application.dart';
import 'application_actions.dart';
import 'application_icon.dart';
import 'application_state_chips.dart';

class ApplicationDetailsContent extends StatelessWidget {
  const ApplicationDetailsContent({
    required this.application,
    required this.isBusy,
    super.key,
  });

  final ManagedApplication application;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final versionCode = application.versionCode;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ApplicationHeader(application: application),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Management state',
          children: [
            InfoRow(
              label: 'Allow/block status',
              value: switch (application.policyStatus) {
                ApplicationPolicyStatus.blocked => 'Blocked (blocklist)',
                ApplicationPolicyStatus.allowed => 'Allowed (allowlist)',
                ApplicationPolicyStatus.unspecified => 'No decision recorded',
              },
            ),
            InfoRow(
              label: 'Suspended',
              value: application.isSuspended ? 'Yes' : 'No',
            ),
            InfoRow(
              label: 'Hidden',
              value: application.isHidden ? 'Yes' : 'No',
            ),
            InfoRow(
              label: 'Enabled',
              value: application.isEnabled ? 'Yes' : 'No',
            ),
            InfoRow(
              label: 'Uninstall blocked',
              value: application.isUninstallBlocked ? 'Yes' : 'No',
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Package',
          children: [
            InfoRow(
              label: 'Package name',
              value: application.packageName,
              selectable: true,
            ),
            InfoRow(label: 'Version name', value: application.versionName),
            InfoRow(label: 'Version code', value: versionCode?.toString()),
            InfoRow(
              label: 'Type',
              value: application.isSystemApplication
                  ? 'System application'
                  : 'User application',
            ),
            InfoRow(
              label: 'Installation source',
              value: application.installerPackageName,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ApplicationActions(application: application, isBusy: isBusy),
      ],
    );
  }
}

class ApplicationHeader extends StatelessWidget {
  const ApplicationHeader({required this.application, super.key});

  final ManagedApplication application;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ApplicationIcon(iconPng: application.iconPng, size: 56),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.applicationName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              ApplicationStateChips(application: application),
            ],
          ),
        ),
      ],
    );
  }
}
