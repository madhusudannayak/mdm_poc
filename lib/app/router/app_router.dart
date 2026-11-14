import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/application_management/presentation/bloc/application_details_bloc.dart';
import '../../features/application_management/presentation/bloc/applications_bloc.dart';
import '../../features/application_management/presentation/pages/application_details_page.dart';
import '../../features/application_management/presentation/pages/installed_applications_page.dart';
import '../../features/application_restrictions/presentation/bloc/schedule_editor_bloc.dart';
import '../../features/application_restrictions/presentation/bloc/time_restriction_bloc.dart';
import '../../features/application_restrictions/presentation/pages/schedule_editor_page.dart';
import '../../features/application_restrictions/presentation/pages/time_restriction_page.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/device_information/presentation/bloc/device_information_bloc.dart';
import '../../features/device_information/presentation/pages/device_information_page.dart';
import '../../features/device_provisioning/presentation/bloc/provisioning_bloc.dart';
import '../../features/device_provisioning/presentation/pages/provisioning_page.dart';
import '../../features/device_security/presentation/bloc/device_security_bloc.dart';
import '../../features/device_security/presentation/pages/device_security_page.dart';
import '../../features/installation_management/presentation/bloc/installation_restrictions_bloc.dart';
import '../../features/installation_management/presentation/pages/installation_restrictions_page.dart';
import '../di/injection.dart';

abstract final class AppRoutes {
  static const String dashboard = '/';
  static const String deviceInformation = '/device-information';
  static const String provisioning = '/provisioning';
  static const String applications = '/applications';
  static const String blockedApplications = '/applications?status=blocked';
  static const String allowedApplications = '/applications?status=allowed';
  static const String applicationPicker = '/applications?pick=true';
  static const String timeRestrictions = '/time-restrictions';
  static const String scheduleEditor = '/time-restrictions/editor';
  static const String installationRestrictions = '/installation-restrictions';
  static const String deviceSecurity = '/device-security';
  static const String _applicationDetails = '/application-details';

  static String applicationDetails(String packageName) =>
      '$_applicationDetails/$packageName';
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
    GoRoute(
      path: AppRoutes.applications,
      builder: (context, state) => BlocProvider<ApplicationsBloc>(
        create: (_) => serviceLocator<ApplicationsBloc>(
          param1: switch (state.uri.queryParameters['status']) {
            'blocked' => ApplicationStatusFilter.blocked,
            'allowed' => ApplicationStatusFilter.allowed,
            _ => ApplicationStatusFilter.any,
          },
        )..add(const ApplicationsRequested()),
        child: InstalledApplicationsPage(
          selectionMode: state.uri.queryParameters['pick'] == 'true',
        ),
      ),
    ),
    GoRoute(
      path: '${AppRoutes._applicationDetails}/:packageName',
      builder: (context, state) => BlocProvider<ApplicationDetailsBloc>(
        create: (_) => serviceLocator<ApplicationDetailsBloc>(
          param1: state.pathParameters['packageName'] ?? '',
        )..add(const ApplicationDetailsRequested()),
        child: const ApplicationDetailsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.timeRestrictions,
      builder: (context, state) => BlocProvider<TimeRestrictionBloc>(
        create: (_) =>
            serviceLocator<TimeRestrictionBloc>()
              ..add(const TimeRestrictionsRequested()),
        child: const TimeRestrictionPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.scheduleEditor,
      // The editor is only reachable with arguments from inside the app.
      redirect: (context, state) =>
          state.extra is ScheduleEditorArgs ? null : AppRoutes.timeRestrictions,
      builder: (context, state) => BlocProvider<ScheduleEditorBloc>(
        create: (_) => serviceLocator<ScheduleEditorBloc>(
          param1: state.extra! as ScheduleEditorArgs,
        ),
        child: const ScheduleEditorPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.installationRestrictions,
      builder: (context, state) => BlocProvider<InstallationRestrictionsBloc>(
        create: (_) =>
            serviceLocator<InstallationRestrictionsBloc>()
              ..add(const InstallationRestrictionsRequested()),
        child: const InstallationRestrictionsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.deviceSecurity,
      builder: (context, state) => BlocProvider<DeviceSecurityBloc>(
        create: (_) =>
            serviceLocator<DeviceSecurityBloc>()
              ..add(const DeviceSecurityRequested()),
        child: const DeviceSecurityPage(),
      ),
    ),
  ],
);
