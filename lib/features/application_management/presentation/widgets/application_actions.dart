import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../application_restrictions/presentation/bloc/schedule_editor_bloc.dart';
import '../../domain/entities/managed_application.dart';
import '../bloc/application_details_bloc.dart';

/// Block/allow and hide/unhide actions. Each asks for confirmation and only
/// then dispatches the event; results come back through the BLoC.
class ApplicationActions extends StatelessWidget {
  const ApplicationActions({
    required this.application,
    required this.isBusy,
    super.key,
  });

  final ManagedApplication application;
  final bool isBusy;

  Future<void> _confirmSuspension(BuildContext context) async {
    final bloc = context.read<ApplicationDetailsBloc>();
    final name = application.applicationName;
    final suspend = !application.isSuspended;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: suspend ? 'Block $name?' : 'Allow $name?',
      message: suspend
          ? 'The application will be suspended. It stays installed, but the '
                'user cannot open it until it is allowed again.'
          : 'The application will be unsuspended and can be opened again.',
      confirmLabel: suspend ? 'BLOCK' : 'ALLOW',
      isDestructive: suspend,
    );
    if (!confirmed) return;
    bloc.add(
      suspend
          ? const ApplicationBlockConfirmed()
          : const ApplicationAllowConfirmed(),
    );
  }

  Future<void> _confirmHidden(BuildContext context) async {
    final bloc = context.read<ApplicationDetailsBloc>();
    final name = application.applicationName;
    final hide = !application.isHidden;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: hide ? 'Hide $name?' : 'Unhide $name?',
      message: hide
          ? 'The application stays installed but disappears from the device '
                'and cannot be used until it is unhidden. This is different '
                'from blocking.'
          : 'The application becomes visible and usable again.',
      confirmLabel: hide ? 'HIDE' : 'UNHIDE',
      isDestructive: hide,
    );
    if (!confirmed) return;
    bloc.add(ApplicationHiddenChangeConfirmed(hidden: hide));
  }

  Future<void> _addTimeRestriction(BuildContext context) async {
    final bloc = context.read<ApplicationDetailsBloc>();
    await context.push<bool>(
      AppRoutes.scheduleEditor,
      extra: ScheduleEditorArgs.create(
        packageName: application.packageName,
        applicationName: application.applicationName,
      ),
    );
    bloc.add(const ApplicationDetailsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: application.isSuspended
              ? 'ALLOW APPLICATION'
              : 'BLOCK APPLICATION',
          icon: application.isSuspended
              ? Icons.check_circle_outline
              : Icons.block,
          isDestructive: !application.isSuspended,
          isBusy: isBusy,
          onPressed: () => _confirmSuspension(context),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isBusy ? null : () => _confirmHidden(context),
            icon: Icon(
              application.isHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            label: Text(
              application.isHidden ? 'UNHIDE APPLICATION' : 'HIDE APPLICATION',
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isBusy ? null : () => _addTimeRestriction(context),
            icon: const Icon(Icons.schedule_outlined),
            label: const Text('ADD TIME RESTRICTION'),
          ),
        ),
      ],
    );
  }
}
