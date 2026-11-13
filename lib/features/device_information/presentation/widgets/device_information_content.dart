import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/management_labels.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/device_information.dart';
import '../bloc/device_information_bloc.dart';

/// Scrollable, pull-to-refresh list of device detail sections.
class DeviceInformationContent extends StatelessWidget {
  const DeviceInformationContent({
    required this.information,
    required this.isRefreshing,
    super.key,
  });

  final DeviceInformation information;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final battery = information.batteryPercentage;
    return RefreshIndicator(
      onRefresh: () {
        final bloc = context.read<DeviceInformationBloc>()
          ..add(const DeviceInformationRefreshed());
        return bloc.stream.firstWhere((state) => !state.isRefreshing);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isRefreshing) const LinearProgressIndicator(),
          SectionCard(
            title: 'Hardware',
            children: [
              InfoRow(label: 'Manufacturer', value: information.manufacturer),
              InfoRow(label: 'Model', value: information.model),
              InfoRow(label: 'Brand', value: information.brand),
              InfoRow(label: 'Device name', value: information.deviceName),
              InfoRow(
                label: 'Battery',
                value: battery == null ? null : '$battery%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Software',
            children: [
              InfoRow(
                label: 'Android version',
                value: information.androidVersion,
              ),
              InfoRow(
                label: 'SDK version',
                value: information.sdkVersion.toString(),
              ),
              InfoRow(
                label: 'Security patch level',
                value: information.securityPatchLevel,
              ),
              InfoRow(
                label: 'Build fingerprint',
                value: information.buildFingerprint,
                selectable: true,
              ),
              InfoRow(
                label: 'Application version',
                value: information.appVersionLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Management',
            children: [
              InfoRow(
                label: 'Device Owner',
                value: information.isDeviceOwner ? 'Active' : 'Not active',
              ),
              InfoRow(
                label: 'Device administrator',
                value: information.isDeviceAdminActive
                    ? 'Active'
                    : 'Not active',
              ),
              InfoRow(
                label: 'Management status',
                value: information.managementMode.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
