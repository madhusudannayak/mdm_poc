import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/platform/mdm_method_channel.dart';
import '../../core/platform/mdm_platform_interface.dart';
import '../../features/application_management/data/repositories/application_repository_impl.dart';
import '../../features/application_management/domain/repositories/application_repository.dart';
import '../../features/application_management/domain/usecases/allow_application_use_case.dart';
import '../../features/application_management/domain/usecases/block_application_use_case.dart';
import '../../features/application_management/domain/usecases/get_application_details_use_case.dart';
import '../../features/application_management/domain/usecases/get_installed_applications_use_case.dart';
import '../../features/application_management/domain/usecases/set_application_hidden_use_case.dart';
import '../../features/application_management/presentation/bloc/application_details_bloc.dart';
import '../../features/application_management/presentation/bloc/applications_bloc.dart';
import '../../features/application_restrictions/data/repositories/schedule_repository_impl.dart';
import '../../features/application_restrictions/domain/repositories/schedule_repository.dart';
import '../../features/application_restrictions/domain/usecases/get_schedule_overview_use_case.dart';
import '../../features/application_restrictions/domain/usecases/remove_schedule_use_case.dart';
import '../../features/application_restrictions/domain/usecases/save_schedule_use_case.dart';
import '../../features/application_restrictions/domain/usecases/set_schedule_enabled_use_case.dart';
import '../../features/application_restrictions/domain/usecases/synchronize_schedules_use_case.dart';
import '../../features/application_restrictions/presentation/bloc/schedule_editor_bloc.dart';
import '../../features/application_restrictions/presentation/bloc/time_restriction_bloc.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_overview_use_case.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/device_information/data/repositories/device_information_repository_impl.dart';
import '../../features/device_information/domain/repositories/device_information_repository.dart';
import '../../features/device_information/domain/usecases/get_device_information_use_case.dart';
import '../../features/device_information/presentation/bloc/device_information_bloc.dart';
import '../../features/device_provisioning/data/repositories/provisioning_repository_impl.dart';
import '../../features/device_security/data/repositories/device_security_repository_impl.dart';
import '../../features/device_security/domain/repositories/device_security_repository.dart';
import '../../features/device_security/domain/usecases/factory_reset_device_use_case.dart';
import '../../features/device_security/domain/usecases/get_device_security_status_use_case.dart';
import '../../features/device_security/domain/usecases/lock_device_use_case.dart';
import '../../features/device_security/presentation/bloc/device_security_bloc.dart';
import '../../features/installation_management/data/repositories/installation_repository_impl.dart';
import '../../features/installation_management/domain/repositories/installation_repository.dart';
import '../../features/installation_management/domain/usecases/get_installation_restriction_status_use_case.dart';
import '../../features/installation_management/domain/usecases/set_installations_blocked_use_case.dart';
import '../../features/installation_management/domain/usecases/set_uninstall_blocked_use_case.dart';
import '../../features/installation_management/domain/usecases/set_unknown_sources_blocked_use_case.dart';
import '../../features/installation_management/presentation/bloc/installation_restrictions_bloc.dart';
import '../../features/device_provisioning/domain/repositories/provisioning_repository.dart';
import '../../features/device_provisioning/domain/usecases/get_provisioning_status_use_case.dart';
import '../../features/device_provisioning/presentation/bloc/provisioning_bloc.dart';

final GetIt serviceLocator = GetIt.instance;

/// Registers the object graph. Singletons are lazy; BLoCs are factories so
/// every route gets a fresh instance.
void configureDependencies() {
  serviceLocator
    // Core
    ..registerLazySingleton<MdmPlatformInterface>(MdmMethodChannel.new)
    ..registerLazySingleton<ApiClient>(ApiClient.new)
    // Dashboard
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(() => GetDashboardOverviewUseCase(serviceLocator()))
    ..registerFactory(() => DashboardBloc(serviceLocator()))
    // Device information
    ..registerLazySingleton<DeviceInformationRepository>(
      () => DeviceInformationRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(() => GetDeviceInformationUseCase(serviceLocator()))
    ..registerFactory(() => DeviceInformationBloc(serviceLocator()))
    // Device provisioning
    ..registerLazySingleton<ProvisioningRepository>(
      () => ProvisioningRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetProvisioningStatusUseCase(serviceLocator()),
    )
    ..registerFactory(() => ProvisioningBloc(serviceLocator()))
    // Application management
    ..registerLazySingleton<ApplicationRepository>(
      () => ApplicationRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetInstalledApplicationsUseCase(serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetApplicationDetailsUseCase(serviceLocator()),
    )
    ..registerLazySingleton(() => BlockApplicationUseCase(serviceLocator()))
    ..registerLazySingleton(() => AllowApplicationUseCase(serviceLocator()))
    ..registerLazySingleton(() => SetApplicationHiddenUseCase(serviceLocator()))
    ..registerFactoryParam<ApplicationsBloc, ApplicationStatusFilter, void>(
      (statusFilter, _) =>
          ApplicationsBloc(serviceLocator(), initialStatusFilter: statusFilter),
    )
    ..registerFactoryParam<ApplicationDetailsBloc, String, void>(
      (packageName, _) => ApplicationDetailsBloc(
        packageName: packageName,
        getApplicationDetails: serviceLocator(),
        blockApplication: serviceLocator(),
        allowApplication: serviceLocator(),
        setApplicationHidden: serviceLocator(),
      ),
    )
    // Time-based application restrictions
    ..registerLazySingleton<ScheduleRepository>(
      () => ScheduleRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(() => GetScheduleOverviewUseCase(serviceLocator()))
    ..registerLazySingleton(() => SaveScheduleUseCase(serviceLocator()))
    ..registerLazySingleton(() => RemoveScheduleUseCase(serviceLocator()))
    ..registerLazySingleton(() => SetScheduleEnabledUseCase(serviceLocator()))
    ..registerLazySingleton(() => SynchronizeSchedulesUseCase(serviceLocator()))
    ..registerFactory(
      () => TimeRestrictionBloc(
        getOverview: serviceLocator(),
        synchronize: serviceLocator(),
        setEnabled: serviceLocator(),
        remove: serviceLocator(),
      ),
    )
    ..registerFactoryParam<ScheduleEditorBloc, ScheduleEditorArgs, void>(
      (args, _) =>
          ScheduleEditorBloc(args: args, saveSchedule: serviceLocator()),
    )
    // Installation restrictions
    ..registerLazySingleton<InstallationRepository>(
      () => InstallationRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetInstallationRestrictionStatusUseCase(serviceLocator()),
    )
    ..registerLazySingleton(
      () => SetInstallationsBlockedUseCase(serviceLocator()),
    )
    ..registerLazySingleton(
      () => SetUnknownSourcesBlockedUseCase(serviceLocator()),
    )
    ..registerLazySingleton(() => SetUninstallBlockedUseCase(serviceLocator()))
    ..registerFactory(
      () => InstallationRestrictionsBloc(
        getStatus: serviceLocator(),
        setInstallationsBlocked: serviceLocator(),
        setUnknownSourcesBlocked: serviceLocator(),
        setUninstallBlocked: serviceLocator(),
      ),
    )
    // Device security
    ..registerLazySingleton<DeviceSecurityRepository>(
      () => DeviceSecurityRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetDeviceSecurityStatusUseCase(serviceLocator()),
    )
    ..registerLazySingleton(() => LockDeviceUseCase(serviceLocator()))
    ..registerLazySingleton(() => FactoryResetDeviceUseCase(serviceLocator()))
    ..registerFactory(
      () => DeviceSecurityBloc(
        getStatus: serviceLocator(),
        lockDevice: serviceLocator(),
        factoryReset: serviceLocator(),
      ),
    );
}
