import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../application_management/domain/entities/managed_application.dart';
import '../bloc/installation_restrictions_bloc.dart';

/// Applications the user is not allowed to uninstall.
class UninstallBlockedSection extends StatelessWidget {
  const UninstallBlockedSection({
    required this.packages,
    required this.isBusy,
    super.key,
  });

  final List<String> packages;
  final bool isBusy;

  Future<void> _add(BuildContext context) async {
    final bloc = context.read<InstallationRestrictionsBloc>();
    final application = await context.push<ManagedApplication>(
      AppRoutes.applicationPicker,
    );
    if (application == null || !context.mounted) return;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Block uninstalling ${application.applicationName}?',
      message:
          'The user will not be able to uninstall this application until '
          'the block is removed.',
      confirmLabel: 'BLOCK UNINSTALL',
    );
    if (confirmed) {
      bloc.add(
        UninstallBlockChangeConfirmed(
          packageName: application.packageName,
          blocked: true,
        ),
      );
    }
  }

  Future<void> _remove(BuildContext context, String packageName) async {
    final bloc = context.read<InstallationRestrictionsBloc>();
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Allow uninstalling?',
      message: 'The user will be able to uninstall $packageName again.',
      confirmLabel: 'ALLOW UNINSTALL',
    );
    if (confirmed) {
      bloc.add(
        UninstallBlockChangeConfirmed(packageName: packageName, blocked: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Uninstall-blocked applications',
      children: [
        if (packages.isEmpty)
          Text(
            'No application is protected from uninstallation.',
            style: theme.textTheme.bodySmall,
          ),
        for (final packageName in packages)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.lock_outline),
            title: Text(packageName),
            trailing: IconButton(
              tooltip: 'Allow uninstall',
              icon: const Icon(Icons.lock_open_outlined),
              onPressed: isBusy ? null : () => _remove(context, packageName),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isBusy ? null : () => _add(context),
            icon: const Icon(Icons.add),
            label: const Text('PROTECT AN APP'),
          ),
        ),
      ],
    );
  }
}
