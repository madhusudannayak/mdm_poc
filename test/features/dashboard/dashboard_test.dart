import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/failure.dart';
import 'package:mdd_poc/core/errors/mdm_exceptions.dart';
import 'package:mdd_poc/core/platform/models/application_schedule_model.dart';
import 'package:mdd_poc/core/platform/models/device_status_models.dart';
import 'package:mdd_poc/core/platform/models/installation_restriction_status_model.dart';
import 'package:mdd_poc/core/platform/models/managed_application_model.dart';
import 'package:mdd_poc/core/platform/models/provisioning_status_model.dart';
import 'package:mdd_poc/core/utils/result.dart';
import 'package:mdd_poc/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mdd_poc/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:mdd_poc/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

const _overview = DashboardOverview(
  managementMode: ManagementMode.deviceAdmin,
  provisioningState: ProvisioningState.deviceAdminActive,
  isDeviceOwner: false,
  isDeviceAdminActive: true,
  installedApplicationCount: 3,
  blockedApplicationCount: 1,
  allowedApplicationCount: 1,
  activeScheduleCount: 1,
  installationsBlocked: false,
  unknownSourcesBlocked: true,
);

const _failure = Failure(code: MdmErrorCodes.platformError, message: 'failed');

void main() {
  group('DashboardRepositoryImpl', () {
    late MockMdmPlatform platform;

    setUp(() => platform = MockMdmPlatform());

    test('combines management and provisioning status', () async {
      when(platform.getDeviceManagementStatus).thenAnswer(
        (_) async => DeviceManagementStatusModel.fromMap(
          managementStatusMap(mode: 'DEVICE_ADMIN', isDeviceAdminActive: true),
        ),
      );
      when(platform.getProvisioningStatus).thenAnswer(
        (_) async => ProvisioningStatusModel.fromMap(
          provisioningStatusMap(
            status: 'DEVICE_ADMIN_ACTIVE',
            isDeviceAdminActive: true,
          ),
        ),
      );

      when(
        () => platform.getInstalledApplications(includeIcons: false),
      ).thenAnswer(
        (_) async => [
          ManagedApplicationModel.fromMap(
            applicationMap(packageName: 'com.a.one', policyStatus: 'BLOCKED'),
          ),
          ManagedApplicationModel.fromMap(
            applicationMap(packageName: 'com.a.two', policyStatus: 'ALLOWED'),
          ),
          ManagedApplicationModel.fromMap(
            applicationMap(packageName: 'com.a.three'),
          ),
        ],
      );

      when(platform.getApplicationSchedules).thenAnswer(
        (_) async => const [
          ApplicationScheduleModel(
            id: 1,
            packageName: 'com.a.one',
            startMinuteOfDay: 540,
            endMinuteOfDay: 1080,
            daysOfWeek: [1],
          ),
          ApplicationScheduleModel(
            id: 2,
            packageName: 'com.a.two',
            startMinuteOfDay: 540,
            endMinuteOfDay: 1080,
            daysOfWeek: [1],
            enabled: false,
          ),
        ],
      );

      when(platform.getInstallationRestrictionStatus).thenAnswer(
        (_) async => const InstallationRestrictionStatusModel(
          installAppsRestricted: false,
          unknownSourcesRestricted: true,
        ),
      );

      final result = await DashboardRepositoryImpl(platform).getOverview();

      expect((result as Success<DashboardOverview>).value, _overview);
    });

    test('a native failure becomes a Failure', () async {
      when(platform.getDeviceManagementStatus).thenThrow(
        const MdmException(
          code: MdmErrorCodes.securityException,
          message: 'denied',
        ),
      );

      final result = await DashboardRepositoryImpl(platform).getOverview();

      expect(
        (result as FailureResult<DashboardOverview>).failure.code,
        MdmErrorCodes.securityException,
      );
    });
  });

  group('DashboardBloc', () {
    late MockGetDashboardOverviewUseCase useCase;

    setUp(() => useCase = MockGetDashboardOverviewUseCase());

    blocTest<DashboardBloc, DashboardState>(
      'emits loading then loaded',
      setUp: () =>
          when(useCase.call).thenAnswer((_) async => const Success(_overview)),
      build: () => DashboardBloc(useCase),
      act: (bloc) => bloc.add(const DashboardOverviewRequested()),
      expect: () => const [DashboardLoading(), DashboardLoaded(_overview)],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits loading then failure',
      setUp: () =>
          when(useCase.call)
              .thenAnswer((_) async => const FailureResult(_failure)),
      build: () => DashboardBloc(useCase),
      act: (bloc) => bloc.add(const DashboardOverviewRequested()),
      expect: () => const [DashboardLoading(), DashboardLoadFailure(_failure)],
    );
  });
}
