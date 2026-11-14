import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/management_labels.dart';
import '../../../../core/widgets/status_card.dart';
import '../../domain/entities/dashboard_overview.dart';
import '../bloc/dashboard_bloc.dart';

/// Dashboard cards. Returning from a detail page reloads the overview so the
/// status always reflects the device, not a cached value.
class DashboardContent extends StatelessWidget {
  const DashboardContent({required this.overview, super.key});

  final DashboardOverview overview;

  Future<void> _open(BuildContext context, String route) async {
    final bloc = context.read<DashboardBloc>();
    await context.push<void>(route);
    bloc.add(const DashboardOverviewRequested());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StatusCard(
          title: 'Device Management Status',
          status: overview.managementMode.label,
          tone: overview.managementMode.tone,
          icon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Device Owner Status',
          status: overview.provisioningState.label,
          tone: overview.provisioningState.tone,
          icon: Icons.admin_panel_settings_outlined,
          description: overview.isDeviceOwner
              ? null
              : 'Open for the provisioning procedure.',
          onTap: () => _open(context, AppRoutes.provisioning),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Device Information',
          description: 'Hardware, software and management details',
          icon: Icons.phone_android_outlined,
          onTap: () => _open(context, AppRoutes.deviceInformation),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Installed Applications',
          status: '${overview.installedApplicationCount} installed',
          icon: Icons.apps_outlined,
          onTap: () => _open(context, AppRoutes.applications),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Blocked Applications',
          status: '${overview.blockedApplicationCount} blocked',
          tone: overview.blockedApplicationCount > 0
              ? StatusTone.negative
              : StatusTone.neutral,
          icon: Icons.block,
          onTap: () => _open(context, AppRoutes.blockedApplications),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Allowed Applications',
          status: '${overview.allowedApplicationCount} allowed',
          tone: overview.allowedApplicationCount > 0
              ? StatusTone.positive
              : StatusTone.neutral,
          icon: Icons.check_circle_outline,
          onTap: () => _open(context, AppRoutes.allowedApplications),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Time-Based Restrictions',
          status: '${overview.activeScheduleCount} active',
          tone: overview.activeScheduleCount > 0
              ? StatusTone.positive
              : StatusTone.neutral,
          icon: Icons.schedule_outlined,
          onTap: () => _open(context, AppRoutes.timeRestrictions),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Installation Restrictions',
          status: overview.installationsBlocked
              ? 'All installations blocked'
              : overview.unknownSourcesBlocked
              ? 'Unknown sources blocked'
              : 'No restrictions',
          tone: overview.installationsBlocked || overview.unknownSourcesBlocked
              ? StatusTone.positive
              : StatusTone.neutral,
          icon: Icons.install_mobile_outlined,
          onTap: () => _open(context, AppRoutes.installationRestrictions),
        ),
        const SizedBox(height: 12),
        StatusCard(
          title: 'Device Security',
          description: 'Lock device, factory reset',
          icon: Icons.security_outlined,
          onTap: () => _open(context, AppRoutes.deviceSecurity),
        ),
      ],
    );
  }
}
