import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/failure.dart';
import 'package:mdd_poc/core/platform/models/native_system_models.dart';
import 'package:mdd_poc/core/utils/result.dart';
import 'package:mdd_poc/features/device_security/data/repositories/device_security_repository_impl.dart';
import 'package:mdd_poc/features/device_security/domain/entities/device_security_status.dart';
import 'package:mdd_poc/features/device_security/presentation/bloc/device_security_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

const _owner = DeviceSecurityStatus(
  isDeviceOwner: true,
  isDeviceAdminActive: true,
  canLockDevice: true,
  canWipeDevice: true,
  isLockScreenSecured: true,
);

const _ownerRequired = Failure(
  code: MdmErrorCodes.deviceOwnerRequired,
  message: 'Device Owner privileges required',
);

void main() {
  group('DeviceSecurityRepositoryImpl', () {
    late MockMdmPlatform platform;
    late DeviceSecurityRepositoryImpl repository;

    setUp(() {
      platform = MockMdmPlatform();
      repository = DeviceSecurityRepositoryImpl(platform);
    });

    test('admin without owner can lock but not wipe', () async {
      when(platform.getNativeCapabilities).thenAnswer(
        (_) async => const NativeCapabilitiesModel(
          sdkInt: 36,
          implementedMethods: [],
          capabilities: {
            'deviceAdminActive': true,
            'deviceOwner': false,
            'deviceLock': true,
            'deviceWipe': false,
          },
        ),
      );

      final status =
          (await repository.getStatus() as Success<DeviceSecurityStatus>).value;

      expect(status.canLockDevice, isTrue);
      expect(status.canWipeDevice, isFalse);
      expect(status.isLockScreenSecured, isFalse);
    });

    test('factory reset always sends explicit confirmation', () async {
      when(() => platform.wipeDevice(confirmed: true)).thenAnswer((_) async {});

      await repository.factoryReset();

      verify(() => platform.wipeDevice(confirmed: true)).called(1);
    });
  });

  group('DeviceSecurityBloc', () {
    late MockGetDeviceSecurityStatusUseCase getStatus;
    late MockLockDeviceUseCase lock;
    late MockFactoryResetDeviceUseCase reset;

    DeviceSecurityBloc build() => DeviceSecurityBloc(
      getStatus: getStatus,
      lockDevice: lock,
      factoryReset: reset,
    );

    setUp(() {
      getStatus = MockGetDeviceSecurityStatusUseCase();
      lock = MockLockDeviceUseCase();
      reset = MockFactoryResetDeviceUseCase();
    });

    blocTest<DeviceSecurityBloc, DeviceSecurityState>(
      'loading the page never locks or wipes',
      setUp: () =>
          when(getStatus.call).thenAnswer((_) async => const Success(_owner)),
      build: build,
      act: (bloc) => bloc.add(const DeviceSecurityRequested()),
      expect: () => const [DeviceSecurityState(security: _owner)],
      verify: (_) {
        verifyNever(lock.call);
        verifyNever(reset.call);
      },
    );

    blocTest<DeviceSecurityBloc, DeviceSecurityState>(
      'lock reports success only after the native call succeeds',
      setUp: () =>
          when(lock.call).thenAnswer((_) async => const Success<void>(null)),
      build: build,
      seed: () => const DeviceSecurityState(security: _owner),
      act: (bloc) => bloc.add(const DeviceLockConfirmed()),
      expect: () => const [
        DeviceSecurityState(
          security: _owner,
          action: DeviceSecurityAction.lock,
          actionStatus: DeviceSecurityActionStatus.inProgress,
        ),
        DeviceSecurityState(
          security: _owner,
          action: DeviceSecurityAction.lock,
          actionStatus: DeviceSecurityActionStatus.success,
          actionMessage: 'Device locked',
        ),
      ],
    );

    blocTest<DeviceSecurityBloc, DeviceSecurityState>(
      'a refused lock shows the native error',
      setUp: () => when(lock.call)
          .thenAnswer((_) async => const FailureResult<void>(_ownerRequired)),
      build: build,
      seed: () => const DeviceSecurityState(security: _owner),
      act: (bloc) => bloc.add(const DeviceLockConfirmed()),
      verify: (bloc) {
        expect(bloc.state.actionStatus, DeviceSecurityActionStatus.failure);
        expect(bloc.state.actionMessage, 'Device Owner privileges required');
      },
    );

    blocTest<DeviceSecurityBloc, DeviceSecurityState>(
      'factory reset runs once, only on the confirmed event',
      setUp: () =>
          when(reset.call).thenAnswer((_) async => const Success<void>(null)),
      build: build,
      seed: () => const DeviceSecurityState(security: _owner),
      act: (bloc) => bloc
        ..add(const FactoryResetConfirmed())
        ..add(const FactoryResetConfirmed()),
      verify: (bloc) {
        verify(reset.call).called(1);
        expect(bloc.state.isFactoryResetInitiated, isTrue);
      },
    );

    blocTest<DeviceSecurityBloc, DeviceSecurityState>(
      'a refused factory reset is reported',
      setUp: () => when(reset.call)
          .thenAnswer((_) async => const FailureResult<void>(_ownerRequired)),
      build: build,
      seed: () => const DeviceSecurityState(security: _owner),
      act: (bloc) => bloc.add(const FactoryResetConfirmed()),
      verify: (bloc) {
        expect(bloc.state.isFactoryResetInitiated, isFalse);
        expect(
          bloc.state.factoryResetError,
          'Device Owner privileges required',
        );
        expect(bloc.state.actionMessage, 'Device Owner privileges required');
      },
    );
  });
}
