import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        actions: const [DashboardRefreshButton()],
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) => switch (state) {
            DashboardLoaded(:final overview) => DashboardContent(
              overview: overview,
            ),
            DashboardLoadFailure(:final failure) => MdmErrorView(
              failure: failure,
              onRetry: () => context.read<DashboardBloc>().add(
                const DashboardOverviewRequested(),
              ),
            ),
            DashboardInitial() || DashboardLoading() => const LoadingWidget(
              message: 'Reading management status',
            ),
          },
        ),
      ),
    );
  }
}

class DashboardRefreshButton extends StatelessWidget {
  const DashboardRefreshButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Refresh',
      icon: const Icon(Icons.refresh),
      onPressed: () =>
          context.read<DashboardBloc>().add(const DashboardOverviewRequested()),
    );
  }
}
