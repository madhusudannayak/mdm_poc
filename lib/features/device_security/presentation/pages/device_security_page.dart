import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/device_security_bloc.dart';
import '../widgets/device_security_content.dart';

class DeviceSecurityPage extends StatelessWidget {
  const DeviceSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Security')),
      body: SafeArea(
        child: BlocConsumer<DeviceSecurityBloc, DeviceSecurityState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus &&
              current.actionMessage != null,
          listener: (context, state) {
            final message = state.actionMessage;
            if (message == null) return;
            final failed =
                state.actionStatus == DeviceSecurityActionStatus.failure;
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
            final failure = state.failure;
            if (state.security != null) {
              return DeviceSecurityContent(state: state);
            }
            if (failure != null) {
              return MdmErrorView(
                failure: failure,
                onRetry: () => context.read<DeviceSecurityBloc>().add(
                  const DeviceSecurityRequested(),
                ),
              );
            }
            return const LoadingWidget(message: 'Reading security status');
          },
        ),
      ),
    );
  }
}
