import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/provisioning_bloc.dart';
import '../widgets/provisioning_content.dart';

class ProvisioningPage extends StatelessWidget {
  const ProvisioningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provisioning'),
        actions: const [ProvisioningRefreshButton()],
      ),
      body: SafeArea(
        child: BlocBuilder<ProvisioningBloc, ProvisioningBlocState>(
          builder: (context, state) => switch (state) {
            ProvisioningLoaded(:final status) => ProvisioningContent(
              status: status,
            ),
            ProvisioningLoadFailure(:final failure) => MdmErrorView(
              failure: failure,
              onRetry: () => context.read<ProvisioningBloc>().add(
                const ProvisioningStatusRequested(),
              ),
            ),
            ProvisioningInitial() || ProvisioningLoading() =>
              const LoadingWidget(message: 'Checking provisioning status'),
          },
        ),
      ),
    );
  }
}

class ProvisioningRefreshButton extends StatelessWidget {
  const ProvisioningRefreshButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Re-check status',
      icon: const Icon(Icons.refresh),
      onPressed: () => context.read<ProvisioningBloc>().add(
        const ProvisioningStatusRequested(),
      ),
    );
  }
}
