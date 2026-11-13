import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/failure.dart';
import 'package:mdd_poc/core/platform/models/provisioning_status_model.dart';
import 'package:mdd_poc/core/utils/result.dart';
import 'package:mdd_poc/features/device_provisioning/data/repositories/provisioning_repository_impl.dart';
import 'package:mdd_poc/features/device_provisioning/domain/entities/provisioning_status.dart';
import 'package:mdd_poc/features/device_provisioning/presentation/bloc/provisioning_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

const _status = ProvisioningStatus(
  state: ProvisioningState.deviceAdminActive,
  isDeviceOwner: false,
  isProfileOwner: false,
  isDeviceAdminActive: true,
  isDeviceAdminSupported: true,
  adminComponent: 'pkg/.Receiver',
  adbProvisioningCommand: 'adb shell dpm set-device-owner pkg/.Receiver',
);

const _failure = Failure(code: MdmErrorCodes.platformError, message: 'failed');

void main() {
  test('repository maps timestamps and state', () async {
    final platform = MockMdmPlatform();
    when(platform.getProvisioningStatus).thenAnswer(
      (_) async => ProvisioningStatusModel.fromMap({
        ...provisioningStatusMap(
          status: 'DEVICE_OWNER_ACTIVE',
          isDeviceOwner: true,
          isDeviceAdminActive: true,
        ),
        'lastAdminEvent': 'ADMIN_ENABLED',
        'lastAdminEventAt': 1000,
      }),
    );

    final result = await ProvisioningRepositoryImpl(platform)
        .getProvisioningStatus();

    final value = (result as Success<ProvisioningStatus>).value;
    expect(value.state, ProvisioningState.deviceOwnerActive);
    expect(value.lastAdminEventAt, DateTime.fromMillisecondsSinceEpoch(1000));
    expect(value.provisioningCompletedAt, isNull);
  });

  group('ProvisioningBloc', () {
    late MockGetProvisioningStatusUseCase useCase;

    setUp(() => useCase = MockGetProvisioningStatusUseCase());

    blocTest<ProvisioningBloc, ProvisioningBlocState>(
      'emits loading then loaded',
      setUp: () =>
          when(useCase.call).thenAnswer((_) async => const Success(_status)),
      build: () => ProvisioningBloc(useCase),
      act: (bloc) => bloc.add(const ProvisioningStatusRequested()),
      expect: () => const [ProvisioningLoading(), ProvisioningLoaded(_status)],
    );

    blocTest<ProvisioningBloc, ProvisioningBlocState>(
      'emits loading then failure',
      setUp: () =>
          when(useCase.call)
              .thenAnswer((_) async => const FailureResult(_failure)),
      build: () => ProvisioningBloc(useCase),
      act: (bloc) => bloc.add(const ProvisioningStatusRequested()),
      expect: () => const [
        ProvisioningLoading(),
        ProvisioningLoadFailure(_failure),
      ],
    );
  });
}
