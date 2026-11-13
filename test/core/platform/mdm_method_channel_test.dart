import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/constants/mdm_constants.dart';
import 'package:mdd_poc/core/errors/mdm_exceptions.dart';
import 'package:mdd_poc/core/platform/mdm_method_channel.dart';
import 'package:mdd_poc/core/platform/models/application_schedule_model.dart';
import 'package:mdd_poc/core/platform/models/device_policy_model.dart';
import 'package:mdd_poc/core/platform/models/device_status_models.dart';
import 'package:mdd_poc/core/platform/models/provisioning_status_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MdmConstants.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  late MdmMethodChannel platform;

  void respondWith(Future<Object?> Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) {
      calls.add(call);
      return handler(call);
    });
  }

  Matcher throwsMdm(String code) =>
      throwsA(isA<MdmException>().having((error) => error.code, 'code', code));

  setUp(() {
    calls.clear();
    platform = MdmMethodChannel();
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('successful calls', () {
    test('getDeviceInfo returns a typed model', () async {
      respondWith((_) async => successEnvelope(deviceInformationMap()));

      final info = await platform.getDeviceInfo();

      expect(calls.single.method, MdmMethods.getDeviceInfo);
      expect(info.manufacturer, 'Google');
      expect(info.sdkVersion, 36);
      expect(info.managementMode, ManagementMode.fullyManaged);
      expect(info.batteryPercentage, 87);
    });

    test('unavailable native values stay null', () async {
      respondWith(
        (_) async => successEnvelope(
          deviceInformationMap(deviceName: null, batteryPercentage: null),
        ),
      );

      final info = await platform.getDeviceInfo();

      expect(info.deviceName, isNull);
      expect(info.batteryPercentage, isNull);
    });

    test('getProvisioningStatus parses the provisioning state', () async {
      respondWith(
        (_) async => successEnvelope(
          provisioningStatusMap(
            status: 'DEVICE_ADMIN_ACTIVE',
            isDeviceAdminActive: true,
          ),
        ),
      );

      final status = await platform.getProvisioningStatus();

      expect(status.state, ProvisioningState.deviceAdminActive);
      expect(status.isDeviceOwner, isFalse);
    });

    test('isDeviceOwner reads the boolean payload', () async {
      respondWith((_) async => successEnvelope({'isDeviceOwner': true}));

      expect(await platform.isDeviceOwner(), isTrue);
    });

    test('suspendApplication sends the package name', () async {
      respondWith((_) async => successEnvelope(null));

      await platform.suspendApplication('com.google.android.youtube');

      expect(calls.single.method, MdmMethods.suspendApplication);
      expect(calls.single.arguments, {
        'packageName': 'com.google.android.youtube',
      });
    });
  });

  group('failures', () {
    test('failure envelope becomes MdmException with its code', () async {
      respondWith(
        (_) async => failureEnvelope(
          MdmErrorCodes.deviceOwnerRequired,
          'Device Owner privileges required',
        ),
      );

      await expectLater(
        platform.lockDevice(),
        throwsA(
          isA<MdmException>()
              .having(
                (error) => error.code,
                'code',
                MdmErrorCodes.deviceOwnerRequired,
              )
              .having(
                (error) => error.message,
                'message',
                'Device Owner privileges required',
              ),
        ),
      );
    });

    test('missing native method becomes NATIVE_METHOD_MISSING', () async {
      // No handler registered: the channel raises MissingPluginException.
      await expectLater(
        platform.getInstalledApplications(),
        throwsMdm(MdmErrorCodes.nativeMethodMissing),
      );
    });

    test('PlatformException keeps its code', () async {
      respondWith(
        (_) async => throw PlatformException(code: 'BOOM', message: 'failed'),
      );

      await expectLater(platform.getDeviceInfo(), throwsMdm('BOOM'));
    });

    test('non-envelope reply becomes INVALID_RESPONSE', () async {
      respondWith((_) async => 'not a map');

      await expectLater(
        platform.getDeviceInfo(),
        throwsMdm(MdmErrorCodes.invalidResponse),
      );
    });

    test('malformed payload becomes INVALID_RESPONSE', () async {
      respondWith((_) async => successEnvelope({'manufacturer': 42}));

      await expectLater(
        platform.getDeviceInfo(),
        throwsMdm(MdmErrorCodes.invalidResponse),
      );
    });
  });

  group('argument validation never reaches native code', () {
    setUp(() => respondWith((_) async => successEnvelope(null)));

    test('invalid package names are rejected', () async {
      for (final name in [
        '',
        'youtube',
        'com..app',
        '1com.app',
        'com.app;rm',
      ]) {
        await expectLater(
          platform.suspendApplication(name),
          throwsMdm(MdmErrorCodes.invalidArgument),
        );
      }
      expect(calls, isEmpty);
    });

    test('wipeDevice requires explicit confirmation', () async {
      await expectLater(
        platform.wipeDevice(confirmed: false),
        throwsMdm(MdmErrorCodes.invalidArgument),
      );
      expect(calls, isEmpty);
    });

    test('schedules with identical start and end are rejected', () async {
      const schedule = ApplicationScheduleModel(
        packageName: 'com.google.android.youtube',
        startMinuteOfDay: 540,
        endMinuteOfDay: 540,
        daysOfWeek: [1, 2, 3],
      );

      await expectLater(
        platform.saveApplicationSchedule(schedule),
        throwsMdm(MdmErrorCodes.invalidArgument),
      );
      expect(calls, isEmpty);
    });

    test('updating a schedule requires a persisted id', () async {
      const schedule = ApplicationScheduleModel(
        packageName: 'com.google.android.youtube',
        startMinuteOfDay: 540,
        endMinuteOfDay: 1080,
        daysOfWeek: [1],
      );

      await expectLater(
        platform.updateApplicationSchedule(schedule),
        throwsMdm(MdmErrorCodes.invalidArgument),
      );
      expect(calls, isEmpty);
    });

    test('policies cannot allow and block the same package', () async {
      const policy = DevicePolicyModel(
        id: 'p1',
        name: 'Conflict',
        version: 1,
        allowedPackages: ['com.example.app'],
        blockedPackages: ['com.example.app'],
      );

      await expectLater(
        platform.applyDevicePolicy(policy),
        throwsMdm(MdmErrorCodes.invalidArgument),
      );
      expect(calls, isEmpty);
    });
  });
}
