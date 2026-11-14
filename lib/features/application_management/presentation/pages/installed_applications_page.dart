import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/applications_bloc.dart';
import '../widgets/application_filter_bar.dart';
import '../widgets/application_list.dart';

class InstalledApplicationsPage extends StatelessWidget {
  const InstalledApplicationsPage({this.selectionMode = false, super.key});

  /// When true, tapping an application returns it to the caller instead of
  /// opening its details.
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectionMode ? 'Select App' : 'Applications'),
        actions: const [ApplicationSortButton(), ApplicationsRefreshButton()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ApplicationFilterBar(),
            Expanded(child: ApplicationsBody(selectionMode: selectionMode)),
          ],
        ),
      ),
    );
  }
}

class ApplicationsBody extends StatelessWidget {
  const ApplicationsBody({required this.selectionMode, super.key});

  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.visibleApplications != current.visibleApplications ||
          previous.applications.length != current.applications.length ||
          previous.failure != current.failure,
      builder: (context, state) {
        final failure = state.failure;
        if (state.status == ApplicationsStatus.failure && failure != null) {
          return MdmErrorView(
            failure: failure,
            onRetry: () => context.read<ApplicationsBloc>().add(
              const ApplicationsRequested(),
            ),
          );
        }
        if (state.status != ApplicationsStatus.success) {
          return const LoadingWidget(message: 'Reading installed applications');
        }
        if (state.visibleApplications.isEmpty) {
          return ApplicationsEmptyView(
            hasInventory: state.applications.isNotEmpty,
          );
        }
        return ApplicationList(
          applications: state.visibleApplications,
          totalCount: state.applications.length,
          selectionMode: selectionMode,
        );
      },
    );
  }
}

class ApplicationsEmptyView extends StatelessWidget {
  const ApplicationsEmptyView({required this.hasInventory, super.key});

  final bool hasInventory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apps_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasInventory
                  ? 'No applications match the current search and filters.'
                  : 'Android returned no installed applications.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicationsRefreshButton extends StatelessWidget {
  const ApplicationsRefreshButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Refresh',
      icon: const Icon(Icons.refresh),
      onPressed: () =>
          context.read<ApplicationsBloc>().add(const ApplicationsRefreshed()),
    );
  }
}
