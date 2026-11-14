import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/installation_restriction_status.dart';
import '../bloc/installation_restrictions_bloc.dart';
import 'restriction_switch_tile.dart';
import 'uninstall_blocked_section.dart';

class InstallationRestrictionsContent extends StatelessWidget {
  const InstallationRestrictionsContent({
    required this.restrictions,
    required this.isBusy,
    super.key,
  });

  final InstallationRestrictionStatus restrictions;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final global = restrictions.unknownSourcesBlockedGlobally;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isBusy) const LinearProgressIndicator(),
        RestrictionSwitchTile(
          title: 'Block all application installations',
          description:
              'Nothing can be installed from any source, including the app '
              'store. (DISALLOW_INSTALL_APPS)',
          value: restrictions.installationsBlocked,
          enabled: !isBusy,
          enableWarning:
              'No application can be installed on this device from any '
              'source, including the app store and ADB, until this '
              'restriction is removed.',
          onConfirmed: (blocked) => context
              .read<InstallationRestrictionsBloc>()
              .add(InstallationBlockChangeConfirmed(blocked: blocked)),
        ),
        const SizedBox(height: 12),
        RestrictionSwitchTile(
          title: 'Block unknown sources',
          description: global == null
              ? 'Blocks sideloading only. Store installations still work.'
              : 'Blocks sideloading only. Store installations still work. '
                    'Device-wide: ${global ? 'enforced' : 'not enforced'}.',
          value: restrictions.unknownSourcesBlocked,
          enabled: !isBusy,
          enableWarning:
              'Applications can no longer be installed from APK files or '
              'other unknown sources. This does not block installations '
              'from the app store.',
          onConfirmed: (blocked) => context
              .read<InstallationRestrictionsBloc>()
              .add(UnknownSourcesBlockChangeConfirmed(blocked: blocked)),
        ),
        const SizedBox(height: 12),
        UninstallBlockedSection(
          packages: restrictions.uninstallBlockedPackages,
          isBusy: isBusy,
        ),
      ],
    );
  }
}
