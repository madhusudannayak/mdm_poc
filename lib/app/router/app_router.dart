import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/device_information/presentation/bloc/device_information_bloc.dart';
import '../../features/device_information/presentation/pages/device_information_page.dart';
import '../../features/device_provisioning/presentation/bloc/provisioning_bloc.dart';
import '../../features/device_provisioning/presentation/pages/provisioning_page.dart';
import '../di/injection.dart';

abstract final class AppRoutes {
  static const String dashboard = '/';
  static const String deviceInformation = '/device-information';
  static const String provisioning = '/provisioning';
}

/// Builds the application router. Each route creates its own BLoC from the
/// service locator and dispatches the initial load event.
GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => BlocProvider<DashboardBloc>(
        create: (_) =>
            serviceLocator<DashboardBloc>()
              ..add(const DashboardOverviewRequested()),
        child: const DashboardPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.deviceInformation,
      builder: (context, state) => BlocProvider<DeviceInformationBloc>(
        create: (_) =>
            serviceLocator<DeviceInformationBloc>()
              ..add(const DeviceInformationRequested()),
        child: const DeviceInformationPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.provisioning,
      builder: (context, state) => BlocProvider<ProvisioningBloc>(
        create: (_) =>
            serviceLocator<ProvisioningBloc>()
              ..add(const ProvisioningStatusRequested()),
        child: const ProvisioningPage(),
      ),
    ),
  ],
);
