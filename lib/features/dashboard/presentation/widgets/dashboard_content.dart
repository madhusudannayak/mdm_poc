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
      ],
    );
  }
}
