import 'package:mdd_poc/core/platform/mdm_platform_interface.dart';
import 'package:mdd_poc/features/dashboard/domain/usecases/get_dashboard_overview_use_case.dart';
import 'package:mdd_poc/features/device_information/domain/usecases/get_device_information_use_case.dart';
import 'package:mdd_poc/features/device_provisioning/domain/usecases/get_provisioning_status_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockMdmPlatform extends Mock implements MdmPlatformInterface {}

class MockGetDeviceInformationUseCase extends Mock
    implements GetDeviceInformationUseCase {}

class MockGetProvisioningStatusUseCase extends Mock
    implements GetProvisioningStatusUseCase {}

class MockGetDashboardOverviewUseCase extends Mock
    implements GetDashboardOverviewUseCase {}
