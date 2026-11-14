import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/device_security_status.dart';
import '../bloc/device_security_bloc.dart';

class DeviceSecurityContent extends StatelessWidget {
  const DeviceSecurityContent({required this.state, super.key});

  final DeviceSecurityState state;

  @override
  Widget build(BuildContext context) {
    final security = state.security;
    if (security == null) return const SizedBox.shrink();
    final factoryResetError = state.factoryResetError;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Status',
          children: [
            InfoRow(
              label: 'Device Owner',
              value: security.isDeviceOwner ? 'Active' : 'Not active',
            ),
            InfoRow(
              label: 'Device administrator',
              value: security.isDeviceAdminActive ? 'Active' : 'Not active',
            ),
            InfoRow(
              label: 'Screen lock',
              value: security.isLockScreenSecured
                  ? 'PIN, pattern or password set'
                  : 'None configured',
            ),
          ],
        ),
        const SizedBox(height: 12),
        LockDeviceCard(
          security: security,
          isBusy: state.isActionInProgress || state.isFactoryResetInitiated,
        ),
        const SizedBox(height: 12),
        if (state.isFactoryResetPending) ...[
          const FactoryResetNotice(
            message:
                'Factory reset requested. The device should restart and '
                'erase its data within a few seconds. If it is still running '
                'in 30 seconds, the reset did not happen and an error is '
                'shown.',
          ),
          const SizedBox(height: 12),
        ],
        if (factoryResetError != null) ...[
          FactoryResetNotice(
            message: 'Factory reset failed. $factoryResetError',
          ),
          const SizedBox(height: 12),
        ],
        FactoryResetCard(
          security: security,
          isBusy: state.isActionInProgress || state.isFactoryResetInitiated,
        ),
      ],
    );
  }
}

class LockDeviceCard extends StatelessWidget {
  const LockDeviceCard({
    required this.security,
    required this.isBusy,
    super.key,
  });

  final DeviceSecurityStatus security;
  final bool isBusy;

  Future<void> _confirm(BuildContext context) async {
    final bloc = context.read<DeviceSecurityBloc>();
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Lock device?',
      message: security.isLockScreenSecured
          ? 'The device will lock immediately and require its screen-lock '
                'credentials to open.'
          : 'The screen will turn off immediately. No screen lock is '
                'configured, so no credentials will be required to open it.',
      confirmLabel: 'LOCK DEVICE',
    );
    if (confirmed) bloc.add(const DeviceLockConfirmed());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Device lock',
      children: [
        Text(
          security.canLockDevice
              ? 'Locks this device immediately.'
              : 'Unavailable: an active device administrator is required.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'LOCK DEVICE',
          icon: Icons.lock_outline,
          isBusy: isBusy,
          onPressed: security.canLockDevice ? () => _confirm(context) : null,
        ),
      ],
    );
  }
}

class FactoryResetCard extends StatelessWidget {
  const FactoryResetCard({
    required this.security,
    required this.isBusy,
    super.key,
  });

  final DeviceSecurityStatus security;
  final bool isBusy;

  Future<void> _confirm(BuildContext context) async {
    final bloc = context.read<DeviceSecurityBloc>();
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'WARNING',
      message: 'This operation may permanently erase all device data.',
      cancelLabel: 'CANCEL',
      confirmLabel: 'CONFIRM FACTORY RESET',
      isDestructive: true,
    );
    if (confirmed) bloc.add(const FactoryResetConfirmed());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Factory reset',
      children: [
        Text(
          security.canWipeDevice
              ? 'Erases all data and returns the device to factory state. '
                    'This cannot be undone. Use only on a dedicated test or '
                    'organization-owned device.'
              : 'Unavailable: Device Owner privileges are required.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'FACTORY RESET',
          icon: Icons.delete_forever_outlined,
          isDestructive: true,
          isBusy: isBusy,
          onPressed: security.canWipeDevice ? () => _confirm(context) : null,
        ),
      ],
    );
  }
}

/// Persistent notice about a pending or failed factory reset.
class FactoryResetNotice extends StatelessWidget {
  const FactoryResetNotice({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
