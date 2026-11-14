import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/failure.dart';
import 'package:mdd_poc/core/platform/models/installation_restriction_status_model.dart';
import 'package:mdd_poc/core/utils/result.dart';
import 'package:mdd_poc/features/installation_management/data/repositories/installation_repository_impl.dart';
import 'package:mdd_poc/features/installation_management/domain/entities/installation_restriction_status.dart';
import 'package:mdd_poc/features/installation_management/presentation/bloc/installation_restrictions_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

const _none = InstallationRestrictionStatus(
  installationsBlocked: false,
  unknownSourcesBlocked: false,
  unknownSourcesBlockedGlobally: false,
  uninstallBlockedPackages: [],
);

const _installsBlocked = InstallationRestrictionStatus(
  installationsBlocked: true,
  unknownSourcesBlocked: false,
  unknownSourcesBlockedGlobally: false,
  uninstallBlockedPackages: [],
);

const _ownerRequired = Failure(
  code: MdmErrorCodes.deviceOwnerRequired,
  message: 'Device Owner privileges required',
);

void main() {
  group('InstallationRepositoryImpl', () {
    late MockMdmPlatform platform;
    late InstallationRepositoryImpl repository;

    setUp(() {
      platform = MockMdmPlatform();
      repository = InstallationRepositoryImpl(platform);
    });

    test('unknown sources and global installs stay distinct', () async {
      when(platform.getInstallationRestrictionStatus).thenAnswer(
        (_) async => const InstallationRestrictionStatusModel(
          installAppsRestricted: false,
          unknownSourcesRestricted: true,
          unknownSourcesGloballyRestricted: true,
          uninstallBlockedPackages: ['com.a.app'],
        ),
      );

      final status =
          (await repository.getStatus()
                  as Success<InstallationRestrictionStatus>)
              .value;

      expect(status.unknownSourcesBlocked, isTrue);
      expect(status.installationsBlocked, isFalse);
      expect(status.uninstallBlockedPackages, ['com.a.app']);
    });

    test('each restriction calls its own native method', () async {
      const model = InstallationRestrictionStatusModel(
        installAppsRestricted: true,
        unknownSourcesRestricted: false,
      );
      when(() => platform.setApplicationInstallationRestriction(enabled: true))
          .thenAnswer((_) async => model);
      when(() => platform.setUnknownSourcesRestriction(enabled: true))
          .thenAnswer((_) async => model);

      await repository.setInstallationsBlocked(blocked: true);
      verify(
        () => platform.setApplicationInstallationRestriction(enabled: true),
      ).called(1);
      verifyNever(
        () => platform.setUnknownSourcesRestriction(
          enabled: any(named: 'enabled'),
        ),
      );

      await repository.setUnknownSourcesBlocked(blocked: true);
      verify(() => platform.setUnknownSourcesRestriction(enabled: true))
          .called(1);
    });
  });

  group('InstallationRestrictionsBloc', () {
    late MockGetInstallationRestrictionStatusUseCase getStatus;
    late MockSetInstallationsBlockedUseCase setInstalls;
    late MockSetUnknownSourcesBlockedUseCase setUnknown;
    late MockSetUninstallBlockedUseCase setUninstall;

    InstallationRestrictionsBloc build() => InstallationRestrictionsBloc(
      getStatus: getStatus,
      setInstallationsBlocked: setInstalls,
      setUnknownSourcesBlocked: setUnknown,
      setUninstallBlocked: setUninstall,
    );

    setUp(() {
      getStatus = MockGetInstallationRestrictionStatusUseCase();
      setInstalls = MockSetInstallationsBlockedUseCase();
      setUnknown = MockSetUnknownSourcesBlockedUseCase();
      setUninstall = MockSetUninstallBlockedUseCase();
    });

    blocTest<InstallationRestrictionsBloc, InstallationRestrictionsState>(
      'shows the effective state re-read from the device after a change',
      setUp: () {
        when(() => setInstalls(blocked: true))
            .thenAnswer((_) async => const Success(_installsBlocked));
        when(getStatus.call)
            .thenAnswer((_) async => const Success(_installsBlocked));
      },
      build: build,
      seed: () => const InstallationRestrictionsState(restrictions: _none),
      act: (bloc) =>
          bloc.add(const InstallationBlockChangeConfirmed(blocked: true)),
      expect: () => const [
        InstallationRestrictionsState(
          restrictions: _none,
          actionStatus: InstallationActionStatus.inProgress,
        ),
        InstallationRestrictionsState(
          restrictions: _installsBlocked,
          actionStatus: InstallationActionStatus.success,
          actionMessage: 'All application installations are blocked',
        ),
      ],
    );

    blocTest<InstallationRestrictionsBloc, InstallationRestrictionsState>(
      'a refused change reports the error and keeps the real state',
      setUp: () {
        when(() => setUnknown(blocked: true))
            .thenAnswer((_) async => const FailureResult(_ownerRequired));
        when(getStatus.call).thenAnswer((_) async => const Success(_none));
      },
      build: build,
      seed: () => const InstallationRestrictionsState(restrictions: _none),
      act: (bloc) =>
          bloc.add(const UnknownSourcesBlockChangeConfirmed(blocked: true)),
      skip: 1,
      expect: () => const [
        InstallationRestrictionsState(
          restrictions: _none,
          actionStatus: InstallationActionStatus.failure,
          actionMessage: 'Device Owner privileges required',
        ),
      ],
    );

    blocTest<InstallationRestrictionsBloc, InstallationRestrictionsState>(
      'uninstall block passes the package and flag through',
      setUp: () {
        when(() => setUninstall('com.a.app', blocked: true))
            .thenAnswer((_) async => const Success<void>(null));
        when(getStatus.call).thenAnswer((_) async => const Success(_none));
      },
      build: build,
      act: (bloc) => bloc.add(
        const UninstallBlockChangeConfirmed(
          packageName: 'com.a.app',
          blocked: true,
        ),
      ),
      verify: (_) =>
          verify(() => setUninstall('com.a.app', blocked: true)).called(1),
    );
  });
}
