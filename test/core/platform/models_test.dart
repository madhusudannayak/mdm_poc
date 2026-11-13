import 'package:flutter_test/flutter_test.dart';
import 'package:mdd_poc/core/errors/mdm_exceptions.dart';
import 'package:mdd_poc/core/platform/models/application_schedule_model.dart';
import 'package:mdd_poc/core/platform/models/device_policy_model.dart';
import 'package:mdd_poc/core/platform/models/device_status_models.dart';
import 'package:mdd_poc/core/platform/models/mdm_response.dart';
import 'package:mdd_poc/core/platform/models/native_system_models.dart';
import 'package:mdd_poc/core/platform/models/provisioning_status_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('MdmResponse parses success and failure envelopes', () {
    final ok = MdmResponse.fromRaw(successEnvelope({'a': 1}), method: 'm');
    final failed = MdmResponse.fromRaw(
      failureEnvelope('DEVICE_OWNER_REQUIRED', 'Device Owner required'),
      method: 'm',
    );

    expect(ok.success, isTrue);
    expect(ok.data, {'a': 1});
    expect(failed.success, isFalse);
    expect(failed.errorCode, 'DEVICE_OWNER_REQUIRED');
  });

  test('MdmResponse rejects an envelope without a success flag', () {
    expect(
      () => MdmResponse.fromRaw({'message': 'x'}, method: 'm'),
      throwsA(isA<MdmException>()),
    );
  });

  test('ProvisioningStatusModel keeps admin and owner distinct', () {
    final model = ProvisioningStatusModel.fromMap(
      provisioningStatusMap(
        status: 'DEVICE_ADMIN_ACTIVE',
        isDeviceAdminActive: true,
      ),
    );

    expect(model.state, ProvisioningState.deviceAdminActive);
    expect(model.isDeviceAdminActive, isTrue);
    expect(model.isDeviceOwner, isFalse);
  });

  test('unknown provisioning state is treated as failed, not owner', () {
    expect(
      ProvisioningState.fromWire('SOMETHING_NEW'),
      ProvisioningState.provisioningFailed,
    );
  });

  test('unknown management mode is treated as unmanaged', () {
    expect(ManagementMode.fromWire('SOMETHING_NEW'), ManagementMode.unmanaged);
  });

  test('ApplicationScheduleModel round-trips and detects overnight', () {
    const schedule = ApplicationScheduleModel(
      id: 7,
      packageName: 'com.example.app',
      startMinuteOfDay: 22 * 60,
      endMinuteOfDay: 6 * 60,
      daysOfWeek: [1, 5],
    );

    expect(ApplicationScheduleModel.fromMap(schedule.toMap()), schedule);
    expect(schedule.crossesMidnight, isTrue);
  });

  test('DevicePolicyModel round-trips', () {
    const policy = DevicePolicyModel(
      id: 'p1',
      name: 'Baseline',
      version: 3,
      blockedPackages: ['com.example.game'],
      installationsBlocked: true,
    );

    expect(DevicePolicyModel.fromMap(policy.toMap()), policy);
  });

  test('NativeCapabilitiesModel reports implemented methods', () {
    final model = NativeCapabilitiesModel.fromMap({
      'sdkInt': 36,
      'implementedMethods': ['getDeviceInfo'],
      'capabilities': {'deviceOwner': false},
    });

    expect(model.implements('getDeviceInfo'), isTrue);
    expect(model.implements('lockDevice'), isFalse);
    expect(model.capabilities['deviceOwner'], isFalse);
  });
}
