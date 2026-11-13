import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/platform/mdm_method_channel.dart';
import '../../core/platform/mdm_platform_interface.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_overview_use_case.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/device_information/data/repositories/device_information_repository_impl.dart';
import '../../features/device_information/domain/repositories/device_information_repository.dart';
import '../../features/device_information/domain/usecases/get_device_information_use_case.dart';
import '../../features/device_information/presentation/bloc/device_information_bloc.dart';
import '../../features/device_provisioning/data/repositories/provisioning_repository_impl.dart';
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
    ..registerFactory(() => ProvisioningBloc(serviceLocator()));
}
