import 'package:mdd_poc/core/platform/mdm_platform_interface.dart';
import 'package:mdd_poc/features/application_management/domain/usecases/allow_application_use_case.dart';
import 'package:mdd_poc/features/application_management/domain/usecases/block_application_use_case.dart';
import 'package:mdd_poc/features/application_management/domain/usecases/get_application_details_use_case.dart';
import 'package:mdd_poc/features/application_management/domain/usecases/get_installed_applications_use_case.dart';
import 'package:mdd_poc/features/application_management/domain/usecases/set_application_hidden_use_case.dart';
import 'package:mdd_poc/features/application_restrictions/domain/usecases/get_schedule_overview_use_case.dart';
import 'package:mdd_poc/features/application_restrictions/domain/usecases/remove_schedule_use_case.dart';
import 'package:mdd_poc/features/application_restrictions/domain/usecases/save_schedule_use_case.dart';
import 'package:mdd_poc/features/application_restrictions/domain/usecases/set_schedule_enabled_use_case.dart';
import 'package:mdd_poc/features/application_restrictions/domain/usecases/synchronize_schedules_use_case.dart';
import 'package:mdd_poc/features/dashboard/domain/usecases/get_dashboard_overview_use_case.dart';
import 'package:mdd_poc/features/device_information/domain/usecases/get_device_information_use_case.dart';
import 'package:mdd_poc/features/device_security/domain/usecases/factory_reset_device_use_case.dart';
import 'package:mdd_poc/features/device_security/domain/usecases/get_device_security_status_use_case.dart';
import 'package:mdd_poc/features/device_security/domain/usecases/lock_device_use_case.dart';
import 'package:mdd_poc/features/installation_management/domain/usecases/get_installation_restriction_status_use_case.dart';
import 'package:mdd_poc/features/installation_management/domain/usecases/set_installations_blocked_use_case.dart';
import 'package:mdd_poc/features/installation_management/domain/usecases/set_uninstall_blocked_use_case.dart';
import 'package:mdd_poc/features/installation_management/domain/usecases/set_unknown_sources_blocked_use_case.dart';
import 'package:mdd_poc/features/device_provisioning/domain/usecases/get_provisioning_status_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockMdmPlatform extends Mock implements MdmPlatformInterface {}

class MockGetDeviceInformationUseCase extends Mock
    implements GetDeviceInformationUseCase {}

class MockGetProvisioningStatusUseCase extends Mock
    implements GetProvisioningStatusUseCase {}

class MockGetDashboardOverviewUseCase extends Mock
    implements GetDashboardOverviewUseCase {}

class MockGetInstalledApplicationsUseCase extends Mock
    implements GetInstalledApplicationsUseCase {}

class MockGetApplicationDetailsUseCase extends Mock
    implements GetApplicationDetailsUseCase {}

class MockBlockApplicationUseCase extends Mock
    implements BlockApplicationUseCase {}

class MockAllowApplicationUseCase extends Mock
    implements AllowApplicationUseCase {}

class MockSetApplicationHiddenUseCase extends Mock
    implements SetApplicationHiddenUseCase {}

class MockGetScheduleOverviewUseCase extends Mock
    implements GetScheduleOverviewUseCase {}

class MockSaveScheduleUseCase extends Mock implements SaveScheduleUseCase {}

class MockRemoveScheduleUseCase extends Mock implements RemoveScheduleUseCase {}

class MockSetScheduleEnabledUseCase extends Mock
    implements SetScheduleEnabledUseCase {}

class MockSynchronizeSchedulesUseCase extends Mock
    implements SynchronizeSchedulesUseCase {}

class MockGetInstallationRestrictionStatusUseCase extends Mock
    implements GetInstallationRestrictionStatusUseCase {}

class MockSetInstallationsBlockedUseCase extends Mock
    implements SetInstallationsBlockedUseCase {}

class MockSetUnknownSourcesBlockedUseCase extends Mock
    implements SetUnknownSourcesBlockedUseCase {}

class MockSetUninstallBlockedUseCase extends Mock
    implements SetUninstallBlockedUseCase {}

class MockGetDeviceSecurityStatusUseCase extends Mock
    implements GetDeviceSecurityStatusUseCase {}

class MockLockDeviceUseCase extends Mock implements LockDeviceUseCase {}

class MockFactoryResetDeviceUseCase extends Mock
    implements FactoryResetDeviceUseCase {}
