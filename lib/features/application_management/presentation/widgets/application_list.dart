import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../domain/entities/managed_application.dart';
import '../bloc/applications_bloc.dart';
import 'application_list_item.dart';

/// Inventory list with pull-to-refresh. Returning from the details page
/// reloads the inventory so changes made there are reflected.
class ApplicationList extends StatelessWidget {
  const ApplicationList({
    required this.applications,
    required this.totalCount,
    this.selectionMode = false,
    super.key,
  });

  final List<ManagedApplication> applications;
  final int totalCount;
  final bool selectionMode;

  Future<void> _openDetails(BuildContext context, String packageName) async {
    final bloc = context.read<ApplicationsBloc>();
    // Drop search focus so the keyboard does not reopen on return.
    FocusManager.instance.primaryFocus?.unfocus();
    await context.push<void>(AppRoutes.applicationDetails(packageName));
    bloc.add(const ApplicationsRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () {
        final bloc = context.read<ApplicationsBloc>()
          ..add(const ApplicationsRefreshed());
        return bloc.stream.firstWhere((state) => !state.isRefreshing);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: applications.length + 1,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Showing ${applications.length} of $totalCount applications',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          final application = applications[index - 1];
          return ApplicationListItem(
            key: ValueKey(application.packageName),
            application: application,
            onTap: () => selectionMode
                ? context.pop(application)
                : _openDetails(context, application.packageName),
          );
        },
      ),
    );
  }
}
