import 'package:flutter/services.dart';

import '../constants/mdm_constants.dart';
import '../errors/mdm_exceptions.dart';
import 'mdm_platform_interface.dart';
import 'models/application_schedule_model.dart';
import 'models/device_information_model.dart';
import 'models/device_policy_model.dart';
import 'models/device_status_models.dart';
import 'models/installation_restriction_status_model.dart';
import 'models/managed_application_model.dart';
import 'models/map_reader.dart';
import 'models/mdm_response.dart';
import 'models/native_system_models.dart';
import 'models/provisioning_status_model.dart';

/// [MdmPlatformInterface] backed by the `com.company.mdm/device_management`
/// MethodChannel. This is the only class in the app that talks to the
/// channel.
///
/// Each call validates its arguments, invokes the native handler, checks the
/// response envelope and converts the payload to a typed model. All failure
/// modes surface as [MdmException]:
///
/// * invalid arguments -> `INVALID_ARGUMENT` (the native side is not called)
/// * method not handled by the native build -> `NATIVE_METHOD_MISSING`
/// * `PlatformException` -> its code, or `PLATFORM_ERROR`
/// * `success: false` envelope -> the native `errorCode`
/// * malformed envelope or payload -> `INVALID_RESPONSE`
class MdmMethodChannel implements MdmPlatformInterface {
  MdmMethodChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(MdmConstants.channelName);

  final MethodChannel _channel;

  // --- Device information -------------------------------------------------

  @override
  Future<DeviceInformationModel> getDeviceInfo() =>
      _invoke(MdmMethods.getDeviceInfo, DeviceInformationModel.fromMap);

  @override
  Future<AndroidVersionModel> getAndroidVersion() =>
      _invoke(MdmMethods.getAndroidVersion, AndroidVersionModel.fromMap);

  @override
  Future<DeviceManagementStatusModel> getDeviceManagementStatus() => _invoke(
    MdmMethods.getDeviceManagementStatus,
    DeviceManagementStatusModel.fromMap,
  );

  @override
  Future<DeviceAdminStatusModel> getDeviceAdminStatus() =>
      _invoke(MdmMethods.getDeviceAdminStatus, DeviceAdminStatusModel.fromMap);

  @override
  Future<DeviceOwnerStatusModel> getDeviceOwnerStatus() =>
      _invoke(MdmMethods.getDeviceOwnerStatus, DeviceOwnerStatusModel.fromMap);

  // --- Device provisioning ------------------------------------------------

  @override
  Future<bool> isDeviceOwner() =>
      _invoke(MdmMethods.isDeviceOwner, _flag('isDeviceOwner'));

  @override
  Future<bool> isDeviceAdminActive() =>
      _invoke(MdmMethods.isDeviceAdminActive, _flag('isDeviceAdminActive'));

  @override
  Future<ProvisioningStatusModel> getProvisioningStatus() => _invoke(
    MdmMethods.getProvisioningStatus,
    ProvisioningStatusModel.fromMap,
  );

  // --- Application management ---------------------------------------------

  @override
  Future<List<ManagedApplicationModel>> getInstalledApplications({
    bool includeSystemApplications = true,
    bool includeIcons = true,
  }) => _invoke(
    MdmMethods.getInstalledApplications,
    _listOf(ManagedApplicationModel.fromMap, 'applications'),
    arguments: {
      'includeSystemApplications': includeSystemApplications,
      'includeIcons': includeIcons,
    },
  );

  @override
  Future<ManagedApplicationModel> getApplicationDetails(String packageName) =>
      _invoke(
        MdmMethods.getApplicationDetails,
        ManagedApplicationModel.fromMap,
        arguments: () => _packageArguments(packageName),
      );

  @override
  Future<void> suspendApplication(String packageName) => _invoke(
    MdmMethods.suspendApplication,
    _ignore,
    arguments: () => _packageArguments(packageName),
  );

  @override
  Future<void> unsuspendApplication(String packageName) => _invoke(
    MdmMethods.unsuspendApplication,
    _ignore,
    arguments: () => _packageArguments(packageName),
  );

  @override
  Future<bool> isApplicationSuspended(String packageName) => _invoke(
    MdmMethods.isApplicationSuspended,
    _flag('isSuspended'),
    arguments: () => _packageArguments(packageName),
  );

  @override
  Future<void> setApplicationHidden(String packageName) => _invoke(
    MdmMethods.setApplicationHidden,
    _ignore,
    arguments: () => _packageArguments(packageName),
  );

  @override
  Future<void> setApplicationUnhidden(String packageName) => _invoke(
    MdmMethods.setApplicationUnhidden,
    _ignore,
    arguments: () => _packageArguments(packageName),
  );

  @override
  Future<void> setApplicationUninstallBlocked(
    String packageName, {
    required bool blocked,
  }) => _invoke(
    MdmMethods.setApplicationUninstallBlocked,
    _ignore,
    arguments: () => {..._packageArguments(packageName), 'blocked': blocked},
  );

  // --- Installation management --------------------------------------------

  @override
  Future<InstallationRestrictionStatusModel>
  setApplicationInstallationRestriction({required bool enabled}) => _invoke(
    MdmMethods.setApplicationInstallationRestriction,
    InstallationRestrictionStatusModel.fromMap,
    arguments: {'enabled': enabled},
  );

  @override
  Future<InstallationRestrictionStatusModel> setUnknownSourcesRestriction({
    required bool enabled,
  }) => _invoke(
    MdmMethods.setUnknownSourcesRestriction,
    InstallationRestrictionStatusModel.fromMap,
    arguments: {'enabled': enabled},
  );

  @override
  Future<InstallationRestrictionStatusModel>
  getInstallationRestrictionStatus() => _invoke(
    MdmMethods.getInstallationRestrictionStatus,
    InstallationRestrictionStatusModel.fromMap,
  );

  // --- Device security ----------------------------------------------------

  @override
  Future<void> lockDevice() => _invoke(MdmMethods.lockDevice, _ignore);

  @override
  Future<void> wipeDevice({required bool confirmed}) => _invoke(
    MdmMethods.wipeDevice,
    _ignore,
    arguments: () {
      if (!confirmed) {
        throw const MdmException.invalidArgument(
          'Factory reset requires explicit confirmation.',
        );
      }
      return {'confirmed': true};
    },
  );

  // --- Scheduling ---------------------------------------------------------

  @override
  Future<ApplicationScheduleModel> saveApplicationSchedule(
    ApplicationScheduleModel schedule,
  ) => _invoke(
    MdmMethods.saveApplicationSchedule,
    ApplicationScheduleModel.fromMap,
    arguments: () {
      _validateSchedule(schedule);
      return schedule.toMap();
    },
  );

  @override
  Future<ApplicationScheduleModel> updateApplicationSchedule(
    ApplicationScheduleModel schedule,
  ) => _invoke(
    MdmMethods.updateApplicationSchedule,
    ApplicationScheduleModel.fromMap,
    arguments: () {
      _validateScheduleId(schedule.id);
      _validateSchedule(schedule);
      return schedule.toMap();
    },
  );

  @override
  Future<void> removeApplicationSchedule(int scheduleId) => _invoke(
    MdmMethods.removeApplicationSchedule,
    _ignore,
    arguments: () => _scheduleIdArguments(scheduleId),
  );

  @override
  Future<List<ApplicationScheduleModel>> getApplicationSchedules() => _invoke(
    MdmMethods.getApplicationSchedules,
    _listOf(ApplicationScheduleModel.fromMap, 'schedules'),
  );

  @override
  Future<void> enableApplicationSchedule(int scheduleId) => _invoke(
    MdmMethods.enableApplicationSchedule,
    _ignore,
    arguments: () => _scheduleIdArguments(scheduleId),
  );

  @override
  Future<void> disableApplicationSchedule(int scheduleId) => _invoke(
    MdmMethods.disableApplicationSchedule,
    _ignore,
    arguments: () => _scheduleIdArguments(scheduleId),
  );

  // --- Policies -----------------------------------------------------------

  @override
  Future<DevicePolicyModel> applyDevicePolicy(DevicePolicyModel policy) =>
      _invoke(
        MdmMethods.applyDevicePolicy,
        DevicePolicyModel.fromMap,
        arguments: () {
          _validatePolicy(policy);
          return policy.toMap();
        },
      );

  @override
  Future<void> removeDevicePolicy(String policyId) => _invoke(
    MdmMethods.removeDevicePolicy,
    _ignore,
    arguments: () {
      if (policyId.trim().isEmpty) {
        throw const MdmException.invalidArgument('Policy id is required.');
      }
      return {'policyId': policyId};
    },
  );

  @override
  Future<List<DevicePolicyModel>> getActiveDevicePolicies() => _invoke(
    MdmMethods.getActiveDevicePolicies,
    _listOf(DevicePolicyModel.fromMap, 'policies'),
  );

  // --- System -------------------------------------------------------------

  @override
  Future<NativeCapabilitiesModel> getNativeCapabilities() => _invoke(
    MdmMethods.getNativeCapabilities,
    NativeCapabilitiesModel.fromMap,
  );

  @override
  Future<List<NativeLogEntryModel>> getNativeLogs({int? limit}) => _invoke(
    MdmMethods.getNativeLogs,
    _listOf(NativeLogEntryModel.fromMap, 'logs'),
    arguments: () {
      if (limit != null && limit <= 0) {
        throw const MdmException.invalidArgument(
          'Log limit must be a positive number.',
        );
      }
      return {'limit': limit};
    },
  );

  @override
  Future<NativePermissionsModel> checkNativePermissions() => _invoke(
    MdmMethods.checkNativePermissions,
    NativePermissionsModel.fromMap,
  );

  // --- Invocation ---------------------------------------------------------

  /// Invokes [method] and converts the envelope payload with [parse].
  ///
  /// [arguments] is either a ready map or a `Map Function()` builder; a
  /// builder runs inside the guarded section so validation failures are
  /// reported through the returned future rather than thrown synchronously.
  Future<T> _invoke<T>(
    String method,
    T Function(Object? data) parse, {
    Object? arguments,
  }) async {
    final Map<String, Object?>? resolvedArguments = switch (arguments) {
      final Map<String, Object?> Function() build => build(),
      final Map<String, Object?> map => map,
      _ => null,
    };

    final Object? raw;
    try {
      raw = await _channel.invokeMethod<Object?>(method, resolvedArguments);
    } on MissingPluginException {
      throw MdmException(
        code: MdmErrorCodes.nativeMethodMissing,
        message:
            'The native Android layer does not implement "$method" in this '
            'build.',
      );
    } on PlatformException catch (error) {
      throw MdmException(
        code: error.code.isEmpty ? MdmErrorCodes.platformError : error.code,
        message: error.message ?? 'Native call "$method" failed.',
      );
    }

    final response = MdmResponse.fromRaw(raw, method: method);
    if (!response.success) {
      throw MdmException(
        code: response.errorCode ?? MdmErrorCodes.unknown,
        message: response.message.isEmpty
            ? 'Native call "$method" failed.'
            : response.message,
      );
    }

    try {
      return parse(response.data);
    } on MdmException {
      rethrow;
    } catch (error) {
      throw MdmException.invalidResponse(
        'Could not read the "$method" result: $error',
      );
    }
  }

  static void _ignore(Object? data) {}

  static bool Function(Object? data) _flag(String key) =>
      (data) => MapReader(data, context: key).boolean(key);

  static List<T> Function(Object? data) _listOf<T>(
    T Function(Object? item) convert,
    String context,
  ) =>
      (data) => MapReader.list(data, convert, context: context);

  // --- Validation ---------------------------------------------------------

  static Map<String, Object?> _packageArguments(String packageName) {
    _validatePackageName(packageName);
    return {'packageName': packageName};
  }

  static void _validatePackageName(String packageName) {
    if (packageName.isEmpty ||
        packageName.length > MdmConstants.maxPackageNameLength ||
        !MdmConstants.packageNamePattern.hasMatch(packageName)) {
      throw MdmException.invalidArgument(
        '"$packageName" is not a valid Android package name.',
      );
    }
  }

  static Map<String, Object?> _scheduleIdArguments(int scheduleId) {
    _validateScheduleId(scheduleId);
    return {'scheduleId': scheduleId};
  }

  static void _validateScheduleId(int? scheduleId) {
    if (scheduleId == null || scheduleId <= 0) {
      throw const MdmException.invalidArgument(
        'A persisted schedule id is required.',
      );
    }
  }

  static void _validateSchedule(ApplicationScheduleModel schedule) {
    _validatePackageName(schedule.packageName);
    for (final minute in [schedule.startMinuteOfDay, schedule.endMinuteOfDay]) {
      if (minute < 0 || minute >= MdmConstants.minutesPerDay) {
        throw const MdmException.invalidArgument(
          'Schedule times must be between 00:00 and 23:59.',
        );
      }
    }
    if (schedule.startMinuteOfDay == schedule.endMinuteOfDay) {
      throw const MdmException.invalidArgument(
        'Schedule start and end times must differ.',
      );
    }
    if (schedule.daysOfWeek.isEmpty ||
        schedule.daysOfWeek.any((day) => day < 1 || day > 7) ||
        schedule.daysOfWeek.toSet().length != schedule.daysOfWeek.length) {
      throw const MdmException.invalidArgument(
        'Schedule days must be unique values from 1 (Monday) to 7 (Sunday).',
      );
    }
  }

  static void _validatePolicy(DevicePolicyModel policy) {
    if (policy.id.trim().isEmpty || policy.name.trim().isEmpty) {
      throw const MdmException.invalidArgument(
        'Policy id and name are required.',
      );
    }
    if (policy.version < 1) {
      throw const MdmException.invalidArgument(
        'Policy version must be 1 or greater.',
      );
    }
    [
      ...policy.allowedPackages,
      ...policy.blockedPackages,
      ...policy.uninstallBlockedPackages,
    ].forEach(_validatePackageName);
    final conflicting = policy.allowedPackages.toSet().intersection(
      policy.blockedPackages.toSet(),
    );
    if (conflicting.isNotEmpty) {
      throw MdmException.invalidArgument(
        'Packages cannot be both allowed and blocked: '
        '${conflicting.join(', ')}.',
      );
    }
  }
}
