import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/failure.dart';
import 'package:mdd_poc/core/platform/models/application_schedule_model.dart';
import 'package:mdd_poc/core/platform/models/native_system_models.dart';
import 'package:mdd_poc/core/utils/result.dart';
import 'package:mdd_poc/features/application_restrictions/data/repositories/schedule_repository_impl.dart';
import 'package:mdd_poc/features/application_restrictions/domain/entities/application_schedule.dart';
import 'package:mdd_poc/features/application_restrictions/presentation/bloc/schedule_editor_bloc.dart';
import 'package:mdd_poc/features/application_restrictions/presentation/bloc/time_restriction_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

const _package = 'com.google.android.youtube';

const _schedule = ApplicationSchedule(
  id: 3,
  packageName: _package,
  applicationName: 'YouTube',
  startMinuteOfDay: 540,
  endMinuteOfDay: 1080,
  daysOfWeek: [1, 2, 3, 4, 5],
  isWithinAllowedWindow: false,
  isApplicationSuspended: true,
);

const _overview = ScheduleOverview(
  schedules: [_schedule],
  canScheduleExactAlarms: true,
);

const _ownerRequired = Failure(
  code: MdmErrorCodes.deviceOwnerRequired,
  message: 'Device Owner privileges required',
);

class _FakeSchedule extends Fake implements ApplicationSchedule {}

class _FakeScheduleModel extends Fake implements ApplicationScheduleModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSchedule());
    registerFallbackValue(_FakeScheduleModel());
  });

  group('ApplicationSchedule', () {
    test('flags a restricted application that is not suspended', () {
      const notEnforced = ApplicationSchedule(
        id: 1,
        packageName: _package,
        startMinuteOfDay: 540,
        endMinuteOfDay: 1080,
        daysOfWeek: [1],
        isWithinAllowedWindow: false,
        isApplicationSuspended: false,
      );
      expect(notEnforced.isNotEnforced, isTrue);
      expect(_schedule.isNotEnforced, isFalse);
    });

    test('detects overnight windows', () {
      const overnight = ApplicationSchedule(
        packageName: _package,
        startMinuteOfDay: 22 * 60,
        endMinuteOfDay: 6 * 60,
        daysOfWeek: [1],
      );
      expect(overnight.crossesMidnight, isTrue);
      expect(_schedule.crossesMidnight, isFalse);
    });
  });

  group('ScheduleRepositoryImpl', () {
    late MockMdmPlatform platform;
    late ScheduleRepositoryImpl repository;

    const savedModel = ApplicationScheduleModel(
      id: 9,
      packageName: _package,
      startMinuteOfDay: 540,
      endMinuteOfDay: 1080,
      daysOfWeek: [1],
      nextTransitionAt: 5000,
    );

    setUp(() {
      platform = MockMdmPlatform();
      repository = ScheduleRepositoryImpl(platform);
    });

    test('overview combines schedules with exact-alarm availability', () async {
      when(platform.getApplicationSchedules)
          .thenAnswer((_) async => const [savedModel]);
      when(platform.checkNativePermissions).thenAnswer(
        (_) async => const NativePermissionsModel(
          permissions: [],
          canScheduleExactAlarms: false,
        ),
      );

      final result = await repository.getOverview();

      final overview = (result as Success<ScheduleOverview>).value;
      expect(overview.canScheduleExactAlarms, isFalse);
      expect(
        overview.schedules.single.nextTransitionAt,
        DateTime.fromMillisecondsSinceEpoch(5000),
      );
    });

    test('a schedule without id is created', () async {
      when(() => platform.saveApplicationSchedule(any()))
          .thenAnswer((_) async => savedModel);

      final result = await repository.saveSchedule(
        const ApplicationSchedule(
          packageName: _package,
          startMinuteOfDay: 540,
          endMinuteOfDay: 1080,
          daysOfWeek: [1],
        ),
      );

      expect((result as Success<ApplicationSchedule>).value.id, 9);
      verifyNever(() => platform.updateApplicationSchedule(any()));
    });

    test('a schedule with id is updated', () async {
      when(() => platform.updateApplicationSchedule(any()))
          .thenAnswer((_) async => savedModel);

      await repository.saveSchedule(_schedule);

      verify(() => platform.updateApplicationSchedule(any())).called(1);
      verifyNever(() => platform.saveApplicationSchedule(any()));
    });

    test('enable and disable use their own native methods', () async {
      when(() => platform.enableApplicationSchedule(any()))
          .thenAnswer((_) async {});
      when(() => platform.disableApplicationSchedule(any()))
          .thenAnswer((_) async {});

      await repository.setScheduleEnabled(3, enabled: true);
      await repository.setScheduleEnabled(3, enabled: false);

      verify(() => platform.enableApplicationSchedule(3)).called(1);
      verify(() => platform.disableApplicationSchedule(3)).called(1);
    });
  });

  group('TimeRestrictionBloc', () {
    late MockGetScheduleOverviewUseCase getOverview;
    late MockSynchronizeSchedulesUseCase synchronize;
    late MockSetScheduleEnabledUseCase setEnabled;
    late MockRemoveScheduleUseCase remove;

    TimeRestrictionBloc build() => TimeRestrictionBloc(
      getOverview: getOverview,
      synchronize: synchronize,
      setEnabled: setEnabled,
      remove: remove,
    );

    setUp(() {
      getOverview = MockGetScheduleOverviewUseCase();
      synchronize = MockSynchronizeSchedulesUseCase();
      setEnabled = MockSetScheduleEnabledUseCase();
      remove = MockRemoveScheduleUseCase();
      when(getOverview.call).thenAnswer((_) async => const Success(_overview));
    });

    blocTest<TimeRestrictionBloc, TimeRestrictionState>(
      'loads schedules',
      build: build,
      act: (bloc) => bloc.add(const TimeRestrictionsRequested()),
      skip: 1,
      expect: () => const [
        TimeRestrictionState(
          status: TimeRestrictionStatus.success,
          overview: _overview,
        ),
      ],
    );

    blocTest<TimeRestrictionBloc, TimeRestrictionState>(
      'manual sync reports what was corrected',
      setUp: () => when(synchronize.call).thenAnswer(
        (_) async => const Success(
          ScheduleSyncReport(
            evaluatedPackages: 1,
            changedPackages: [_package],
            failures: [],
          ),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(const TimeRestrictionsSyncRequested()),
      skip: 1,
      expect: () => const [
        TimeRestrictionState(
          status: TimeRestrictionStatus.success,
          overview: _overview,
          actionStatus: TimeRestrictionActionStatus.success,
          actionMessage: 'Corrected 1 of 1 scheduled application(s)',
        ),
      ],
    );

    blocTest<TimeRestrictionBloc, TimeRestrictionState>(
      'a sync with enforcement failures is reported as a failure',
      setUp: () => when(synchronize.call).thenAnswer(
        (_) async => const Success(
          ScheduleSyncReport(
            evaluatedPackages: 1,
            changedPackages: [],
            failures: [
              ScheduleSyncFailure(packageName: _package, message: 'refused'),
            ],
          ),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(const TimeRestrictionsSyncRequested()),
      verify: (bloc) {
        expect(bloc.state.actionStatus, TimeRestrictionActionStatus.failure);
        expect(bloc.state.actionMessage, contains('refused'));
      },
    );

    blocTest<TimeRestrictionBloc, TimeRestrictionState>(
      'deleting removes the schedule and reloads',
      setUp: () =>
          when(() => remove(3))
              .thenAnswer((_) async => const Success<void>(null)),
      build: build,
      act: (bloc) => bloc.add(const TimeRestrictionDeleteConfirmed(3)),
      verify: (bloc) {
        verify(() => remove(3)).called(1);
        verify(getOverview.call).called(1);
        expect(bloc.state.actionMessage, 'Schedule deleted');
      },
    );

    blocTest<TimeRestrictionBloc, TimeRestrictionState>(
      'a refused enable surfaces the native error',
      setUp: () => when(() => setEnabled(3, enabled: true))
          .thenAnswer((_) async => const FailureResult<void>(_ownerRequired)),
      build: build,
      act: (bloc) => bloc.add(
        const TimeRestrictionEnabledChanged(scheduleId: 3, enabled: true),
      ),
      verify: (bloc) {
        expect(bloc.state.actionStatus, TimeRestrictionActionStatus.failure);
        expect(bloc.state.actionMessage, 'Device Owner privileges required');
      },
    );
  });

  group('ScheduleEditorBloc', () {
    late MockSaveScheduleUseCase save;

    ScheduleEditorBloc build([ScheduleEditorArgs? args]) => ScheduleEditorBloc(
      args:
          args ??
          const ScheduleEditorArgs.create(
            packageName: _package,
            applicationName: 'YouTube',
          ),
      saveSchedule: save,
    );

    setUp(() => save = MockSaveScheduleUseCase());

    test('a new schedule defaults to weekdays 09:00-18:00', () {
      final state = build().state;
      expect(state.startMinuteOfDay, 540);
      expect(state.endMinuteOfDay, 1080);
      expect(state.daysOfWeek, {1, 2, 3, 4, 5});
      expect(state.isEditingExisting, isFalse);
    });

    test('editing starts from the existing schedule', () {
      final state = build(ScheduleEditorArgs.edit(_schedule)).state;
      expect(state.scheduleId, 3);
      expect(state.isEditingExisting, isTrue);
    });

    blocTest<ScheduleEditorBloc, ScheduleEditorState>(
      'toggling days adds and removes them',
      build: build,
      act: (bloc) => bloc
        ..add(const ScheduleDayToggled(1))
        ..add(const ScheduleDayToggled(6)),
      verify: (bloc) => expect(bloc.state.daysOfWeek, {2, 3, 4, 5, 6}),
    );

    blocTest<ScheduleEditorBloc, ScheduleEditorState>(
      'invalid input is rejected without calling native code',
      build: build,
      act: (bloc) => bloc
        ..add(const ScheduleEndTimeChanged(540))
        ..add(const ScheduleSubmitted()),
      verify: (bloc) {
        expect(bloc.state.submitStatus, ScheduleSubmitStatus.failure);
        expect(bloc.state.errorMessage, isNotNull);
        verifyNever(() => save(any()));
      },
    );

    blocTest<ScheduleEditorBloc, ScheduleEditorState>(
      'submits an overnight schedule with sorted days',
      setUp: () =>
          when(() => save(any()))
              .thenAnswer((_) async => const Success(_schedule)),
      build: build,
      act: (bloc) => bloc
        ..add(const ScheduleStartTimeChanged(22 * 60))
        ..add(const ScheduleEndTimeChanged(6 * 60))
        ..add(const ScheduleSubmitted()),
      verify: (bloc) {
        expect(bloc.state.submitStatus, ScheduleSubmitStatus.success);
        final sent =
            verify(() => save(captureAny())).captured.single
                as ApplicationSchedule;
        expect(sent.id, isNull);
        expect(sent.startMinuteOfDay, 22 * 60);
        expect(sent.endMinuteOfDay, 6 * 60);
        expect(sent.daysOfWeek, [1, 2, 3, 4, 5]);
        expect(sent.crossesMidnight, isTrue);
      },
    );

    blocTest<ScheduleEditorBloc, ScheduleEditorState>(
      'a native refusal is shown and the editor stays open',
      setUp: () =>
          when(() => save(any()))
              .thenAnswer((_) async => const FailureResult(_ownerRequired)),
      build: build,
      act: (bloc) => bloc.add(const ScheduleSubmitted()),
      verify: (bloc) {
        expect(bloc.state.submitStatus, ScheduleSubmitStatus.failure);
        expect(bloc.state.errorMessage, 'Device Owner privileges required');
      },
    );
  });
}
