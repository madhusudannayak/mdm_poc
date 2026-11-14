import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/failure.dart';
import 'package:mdd_poc/core/errors/mdm_exceptions.dart';
import 'package:mdd_poc/core/platform/models/managed_application_model.dart';
import 'package:mdd_poc/core/utils/result.dart';
import 'package:mdd_poc/features/application_management/data/repositories/application_repository_impl.dart';
import 'package:mdd_poc/features/application_management/domain/entities/managed_application.dart';
import 'package:mdd_poc/features/application_management/presentation/bloc/application_details_bloc.dart';
import 'package:mdd_poc/features/application_management/presentation/bloc/applications_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

ManagedApplication _app(
  String packageName,
  String name, {
  bool system = false,
  bool suspended = false,
  ApplicationPolicyStatus policy = ApplicationPolicyStatus.unspecified,
}) => ManagedApplication(
  packageName: packageName,
  applicationName: name,
  isSystemApplication: system,
  isEnabled: true,
  isSuspended: suspended,
  isHidden: false,
  isUninstallBlocked: false,
  policyStatus: policy,
);

final _youtube = _app('com.google.android.youtube', 'YouTube');
final _youtubeBlocked = _app(
  'com.google.android.youtube',
  'YouTube',
  suspended: true,
  policy: ApplicationPolicyStatus.blocked,
);
final _settings = _app('com.android.settings', 'Settings', system: true);
final _chrome = _app(
  'com.android.chrome',
  'Chrome',
  suspended: true,
  policy: ApplicationPolicyStatus.blocked,
);
final _inventory = [_youtube, _settings, _chrome];

const _ownerRequired = Failure(
  code: MdmErrorCodes.deviceOwnerRequired,
  message: 'Device Owner privileges required',
);

void main() {
  group('ApplicationRepositoryImpl', () {
    late MockMdmPlatform platform;
    late ApplicationRepositoryImpl repository;

    setUp(() {
      platform = MockMdmPlatform();
      repository = ApplicationRepositoryImpl(platform);
    });

    test('maps inventory models to entities', () async {
      when(() => platform.getInstalledApplications()).thenAnswer(
        (_) async => [
          ManagedApplicationModel.fromMap(
            applicationMap(isSuspended: true, policyStatus: 'BLOCKED'),
          ),
        ],
      );

      final result = await repository.getInstalledApplications();

      final apps = (result as Success<List<ManagedApplication>>).value;
      expect(apps.single.packageName, 'com.google.android.youtube');
      expect(apps.single.isSuspended, isTrue);
      expect(apps.single.isBlocked, isTrue);
    });

    test('blocking calls native suspend', () async {
      when(() => platform.suspendApplication(any())).thenAnswer((_) async {});

      final result = await repository.blockApplication('com.a.app');

      expect(result, isA<Success<void>>());
      verify(() => platform.suspendApplication('com.a.app')).called(1);
    });

    test('a non-suspendable package surfaces its error code', () async {
      when(() => platform.suspendApplication(any())).thenThrow(
        const MdmException(
          code: MdmErrorCodes.packageNotSuspendable,
          message: 'Android refused',
        ),
      );

      final result = await repository.blockApplication('com.android.launcher');

      expect(
        (result as FailureResult<void>).failure.code,
        MdmErrorCodes.packageNotSuspendable,
      );
    });

    test('hide and unhide use their own native methods', () async {
      when(() => platform.setApplicationHidden(any())).thenAnswer((_) async {});
      when(() => platform.setApplicationUnhidden(any()))
          .thenAnswer((_) async {});

      await repository.setApplicationHidden('com.a.app', hidden: true);
      await repository.setApplicationHidden('com.a.app', hidden: false);

      verify(() => platform.setApplicationHidden('com.a.app')).called(1);
      verify(() => platform.setApplicationUnhidden('com.a.app')).called(1);
      verifyNever(() => platform.suspendApplication(any()));
    });
  });

  group('ApplicationsBloc', () {
    late MockGetInstalledApplicationsUseCase getApplications;

    setUp(() {
      getApplications = MockGetInstalledApplicationsUseCase();
      when(() => getApplications())
          .thenAnswer((_) async => Success(_inventory));
    });

    List<String> names(ApplicationsState state) => [
      for (final app in state.visibleApplications) app.applicationName,
    ];

    blocTest<ApplicationsBloc, ApplicationsState>(
      'loads the inventory sorted by name',
      build: () => ApplicationsBloc(getApplications),
      act: (bloc) => bloc.add(const ApplicationsRequested()),
      skip: 1,
      verify: (bloc) {
        expect(bloc.state.status, ApplicationsStatus.success);
        expect(names(bloc.state), ['Chrome', 'Settings', 'YouTube']);
      },
    );

    blocTest<ApplicationsBloc, ApplicationsState>(
      'searches by application name and by package name',
      build: () => ApplicationsBloc(getApplications),
      act: (bloc) async {
        bloc.add(const ApplicationsRequested());
        await bloc.stream.firstWhere(
          (state) => state.status == ApplicationsStatus.success,
        );
        bloc.add(const ApplicationsSearchChanged('you'));
        await bloc.stream.first;
        expect(names(bloc.state), ['YouTube']);
        bloc.add(const ApplicationsSearchChanged('android.chrome'));
      },
      verify: (bloc) => expect(names(bloc.state), ['Chrome']),
    );

    blocTest<ApplicationsBloc, ApplicationsState>(
      'filters system and user applications',
      build: () => ApplicationsBloc(getApplications),
      act: (bloc) => bloc
        ..add(const ApplicationsRequested())
        ..add(
          const ApplicationsTypeFilterChanged(ApplicationTypeFilter.system),
        ),
      verify: (bloc) => expect(names(bloc.state), ['Settings']),
    );

    blocTest<ApplicationsBloc, ApplicationsState>(
      'starts with the requested status filter',
      build: () => ApplicationsBloc(
        getApplications,
        initialStatusFilter: ApplicationStatusFilter.blocked,
      ),
      act: (bloc) => bloc.add(const ApplicationsRequested()),
      verify: (bloc) => expect(names(bloc.state), ['Chrome']),
    );

    blocTest<ApplicationsBloc, ApplicationsState>(
      'sorts suspended applications first',
      build: () => ApplicationsBloc(getApplications),
      act: (bloc) => bloc
        ..add(const ApplicationsRequested())
        ..add(const ApplicationsSortChanged(ApplicationSort.blockedFirst)),
      verify: (bloc) =>
          expect(names(bloc.state), ['Chrome', 'Settings', 'YouTube']),
    );

    blocTest<ApplicationsBloc, ApplicationsState>(
      'a failed refresh clears the stale inventory',
      build: () => ApplicationsBloc(getApplications),
      act: (bloc) async {
        bloc.add(const ApplicationsRequested());
        await bloc.stream.firstWhere(
          (state) => state.status == ApplicationsStatus.success,
        );
        when(() => getApplications())
            .thenAnswer((_) async => const FailureResult(_ownerRequired));
        bloc.add(const ApplicationsRefreshed());
      },
      verify: (bloc) {
        expect(bloc.state.status, ApplicationsStatus.failure);
        expect(bloc.state.applications, isEmpty);
        expect(bloc.state.failure, _ownerRequired);
      },
    );
  });

  group('ApplicationDetailsBloc', () {
    const packageName = 'com.google.android.youtube';
    late MockGetApplicationDetailsUseCase getDetails;
    late MockBlockApplicationUseCase block;
    late MockAllowApplicationUseCase allow;
    late MockSetApplicationHiddenUseCase setHidden;

    ApplicationDetailsBloc build() => ApplicationDetailsBloc(
      packageName: packageName,
      getApplicationDetails: getDetails,
      blockApplication: block,
      allowApplication: allow,
      setApplicationHidden: setHidden,
    );

    setUp(() {
      getDetails = MockGetApplicationDetailsUseCase();
      block = MockBlockApplicationUseCase();
      allow = MockAllowApplicationUseCase();
      setHidden = MockSetApplicationHiddenUseCase();
    });

    blocTest<ApplicationDetailsBloc, ApplicationDetailsState>(
      'blocking reports success only after native success, with real state',
      setUp: () {
        when(() => block(packageName))
            .thenAnswer((_) async => const Success<void>(null));
        when(() => getDetails(packageName))
            .thenAnswer((_) async => Success(_youtubeBlocked));
      },
      build: build,
      seed: () => ApplicationDetailsState(
        status: ApplicationDetailsStatus.success,
        application: _youtube,
      ),
      act: (bloc) => bloc.add(const ApplicationBlockConfirmed()),
      expect: () => [
        ApplicationDetailsState(
          status: ApplicationDetailsStatus.success,
          application: _youtube,
          actionStatus: ApplicationActionStatus.inProgress,
        ),
        ApplicationDetailsState(
          status: ApplicationDetailsStatus.success,
          application: _youtubeBlocked,
          actionStatus: ApplicationActionStatus.success,
          actionMessage: 'Application blocked',
        ),
      ],
    );

    blocTest<ApplicationDetailsBloc, ApplicationDetailsState>(
      'a refused block reports the native error and keeps the real state',
      setUp: () {
        when(() => block(packageName))
            .thenAnswer((_) async => const FailureResult<void>(_ownerRequired));
        when(() => getDetails(packageName))
            .thenAnswer((_) async => Success(_youtube));
      },
      build: build,
      seed: () => ApplicationDetailsState(
        status: ApplicationDetailsStatus.success,
        application: _youtube,
      ),
      act: (bloc) => bloc.add(const ApplicationBlockConfirmed()),
      skip: 1,
      expect: () => [
        ApplicationDetailsState(
          status: ApplicationDetailsStatus.success,
          application: _youtube,
          actionStatus: ApplicationActionStatus.failure,
          actionMessage: 'Device Owner privileges required',
        ),
      ],
    );

    blocTest<ApplicationDetailsBloc, ApplicationDetailsState>(
      'allowing calls the allow use case, not block',
      setUp: () {
        when(() => allow(packageName))
            .thenAnswer((_) async => const Success<void>(null));
        when(() => getDetails(packageName))
            .thenAnswer((_) async => Success(_youtube));
      },
      build: build,
      seed: () => ApplicationDetailsState(
        status: ApplicationDetailsStatus.success,
        application: _youtubeBlocked,
      ),
      act: (bloc) => bloc.add(const ApplicationAllowConfirmed()),
      verify: (_) {
        verify(() => allow(packageName)).called(1);
        verifyNever(() => block(any()));
      },
    );
  });
}
