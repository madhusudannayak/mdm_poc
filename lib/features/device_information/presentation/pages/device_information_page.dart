import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/device_information_bloc.dart';
import '../widgets/device_information_content.dart';

class DeviceInformationPage extends StatelessWidget {
  const DeviceInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        actions: const [DeviceInformationRefreshButton()],
      ),
      body: SafeArea(
        child: BlocBuilder<DeviceInformationBloc, DeviceInformationState>(
          builder: (context, state) {
            final information = state.information;
            final failure = state.failure;
            if (information != null) {
              return DeviceInformationContent(
                information: information,
                isRefreshing: state.isRefreshing,
              );
            }
            if (failure != null) {
              return MdmErrorView(
                failure: failure,
                onRetry: () => context.read<DeviceInformationBloc>().add(
                  const DeviceInformationRequested(),
                ),
              );
            }
            return const LoadingWidget(message: 'Reading device information');
          },
        ),
      ),
    );
  }
}

class DeviceInformationRefreshButton extends StatelessWidget {
  const DeviceInformationRefreshButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Refresh',
      icon: const Icon(Icons.refresh),
      onPressed: () => context.read<DeviceInformationBloc>().add(
        const DeviceInformationRefreshed(),
      ),
    );
  }
}
