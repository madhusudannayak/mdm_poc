import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/failure.dart';
import 'package:mdd_poc/core/errors/mdm_exceptions.dart';
import 'package:mdd_poc/core/platform/models/device_information_model.dart';
import 'package:mdd_poc/core/platform/models/device_status_models.dart';
import 'package:mdd_poc/core/utils/result.dart';
import 'package:mdd_poc/features/device_information/data/repositories/device_information_repository_impl.dart';
import 'package:mdd_poc/features/device_information/domain/entities/device_information.dart';
import 'package:mdd_poc/features/device_information/presentation/bloc/device_information_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

const _information = DeviceInformation(
  manufacturer: 'Google',
  model: 'Pixel 7 Pro',
  brand: 'google',
  androidVersion: '16',
  sdkVersion: 36,
  buildFingerprint: 'fp',
  isDeviceOwner: false,
  isDeviceAdminActive: false,
  managementMode: ManagementMode.unmanaged,
);

const _failure = Failure(
  code: MdmErrorCodes.operationFailed,
  message: 'native failure',
);

void main() {
  group('DeviceInformationRepositoryImpl', () {
    late MockMdmPlatform platform;
    late DeviceInformationRepositoryImpl repository;

    setUp(() {
      platform = MockMdmPlatform();
      repository = DeviceInformationRepositoryImpl(platform);
    });

    test('maps the platform model to the entity', () async {
      when(platform.getDeviceInfo).thenAnswer(
        (_) async => DeviceInformationModel.fromMap(deviceInformationMap()),
      );

      final result = await repository.getDeviceInformation();

      final value = (result as Success<DeviceInformation>).value;
      expect(value.model, 'Pixel 7 Pro');
      expect(value.managementMode, ManagementMode.fullyManaged);
      expect(value.appVersionLabel, '1.0.0 (1)');
    });

    test('converts MdmException into a Failure', () async {
      when(platform.getDeviceInfo).thenThrow(
        const MdmException(
          code: MdmErrorCodes.nativeMethodMissing,
          message: 'missing',
        ),
      );

      final result = await repository.getDeviceInformation();

      final failure = (result as FailureResult<DeviceInformation>).failure;
      expect(failure.code, MdmErrorCodes.nativeMethodMissing);
      expect(failure.isNativeMethodMissing, isTrue);
    });
  });

  group('DeviceInformationBloc', () {
    late MockGetDeviceInformationUseCase useCase;

    setUp(() => useCase = MockGetDeviceInformationUseCase());

    blocTest<DeviceInformationBloc, DeviceInformationState>(
      'emits loading then success',
      setUp: () =>
          when(useCase.call)
              .thenAnswer((_) async => const Success(_information)),
      build: () => DeviceInformationBloc(useCase),
      act: (bloc) => bloc.add(const DeviceInformationRequested()),
      expect: () => const [
        DeviceInformationState(status: DeviceInformationStatus.loading),
        DeviceInformationState(
          status: DeviceInformationStatus.success,
          information: _information,
        ),
      ],
    );

    blocTest<DeviceInformationBloc, DeviceInformationState>(
      'emits loading then failure',
      setUp: () =>
          when(useCase.call)
              .thenAnswer((_) async => const FailureResult(_failure)),
      build: () => DeviceInformationBloc(useCase),
      act: (bloc) => bloc.add(const DeviceInformationRequested()),
      expect: () => const [
        DeviceInformationState(status: DeviceInformationStatus.loading),
        DeviceInformationState(
          status: DeviceInformationStatus.failure,
          failure: _failure,
        ),
      ],
    );

    blocTest<DeviceInformationBloc, DeviceInformationState>(
      'refresh keeps data visible, and a failed refresh drops stale data',
      setUp: () =>
          when(useCase.call)
              .thenAnswer((_) async => const FailureResult(_failure)),
      build: () => DeviceInformationBloc(useCase),
      seed: () => const DeviceInformationState(
        status: DeviceInformationStatus.success,
        information: _information,
      ),
      act: (bloc) => bloc.add(const DeviceInformationRefreshed()),
      expect: () => const [
        DeviceInformationState(
          status: DeviceInformationStatus.success,
          information: _information,
          isRefreshing: true,
        ),
        DeviceInformationState(
          status: DeviceInformationStatus.failure,
          failure: _failure,
        ),
      ],
    );
  });
}
