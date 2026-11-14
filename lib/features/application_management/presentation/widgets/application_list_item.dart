import 'package:flutter/material.dart';

import '../../domain/entities/managed_application.dart';
import 'application_icon.dart';
import 'application_state_chips.dart';

class ApplicationListItem extends StatelessWidget {
  const ApplicationListItem({
    required this.application,
    required this.onTap,
    super.key,
  });

  final ManagedApplication application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: ApplicationIcon(iconPng: application.iconPng),
      title: Text(
        application.applicationName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            application.packageName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          ApplicationStateChips(application: application),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
