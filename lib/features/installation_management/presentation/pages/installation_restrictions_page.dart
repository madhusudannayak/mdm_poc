import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/installation_restrictions_bloc.dart';
import '../widgets/installation_restrictions_content.dart';

class InstallationRestrictionsPage extends StatelessWidget {
  const InstallationRestrictionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Install Restrictions'),
        actions: const [InstallationRestrictionsRefreshButton()],
      ),
      body: SafeArea(
        child:
            BlocConsumer<
              InstallationRestrictionsBloc,
              InstallationRestrictionsState
            >(
              listenWhen: (previous, current) =>
                  previous.actionStatus != current.actionStatus &&
                  current.actionMessage != null,
              listener: (context, state) {
                final message = state.actionMessage;
                if (message == null) return;
                final failed =
                    state.actionStatus == InstallationActionStatus.failure;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: failed
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  );
              },
              builder: (context, state) {
                final restrictions = state.restrictions;
                final failure = state.failure;
                if (restrictions != null) {
                  return InstallationRestrictionsContent(
                    restrictions: restrictions,
                    isBusy: state.isActionInProgress,
                  );
                }
                if (failure != null) {
                  return MdmErrorView(
                    failure: failure,
                    onRetry: () => context
                        .read<InstallationRestrictionsBloc>()
                        .add(const InstallationRestrictionsRequested()),
                  );
                }
                return const LoadingWidget(
                  message: 'Reading installation policy',
                );
              },
            ),
      ),
    );
  }
}

class InstallationRestrictionsRefreshButton extends StatelessWidget {
  const InstallationRestrictionsRefreshButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Refresh',
      icon: const Icon(Icons.refresh),
      onPressed: () => context.read<InstallationRestrictionsBloc>().add(
        const InstallationRestrictionsRequested(),
      ),
    );
  }
}
