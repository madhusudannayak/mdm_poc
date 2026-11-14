import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/application_details_bloc.dart';
import '../widgets/application_details_content.dart';

class ApplicationDetailsPage extends StatelessWidget {
  const ApplicationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Details')),
      body: SafeArea(
        child: BlocConsumer<ApplicationDetailsBloc, ApplicationDetailsState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus &&
              current.actionMessage != null,
          listener: (context, state) {
            final message = state.actionMessage;
            if (message == null) return;
            final failed =
                state.actionStatus == ApplicationActionStatus.failure;
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
            final application = state.application;
            final failure = state.failure;
            if (application != null) {
              return ApplicationDetailsContent(
                application: application,
                isBusy: state.isActionInProgress,
              );
            }
            if (failure != null) {
              return MdmErrorView(
                failure: failure,
                onRetry: () => context.read<ApplicationDetailsBloc>().add(
                  const ApplicationDetailsRequested(),
                ),
              );
            }
            return const LoadingWidget(message: 'Reading application details');
          },
        ),
      ),
    );
  }
}
