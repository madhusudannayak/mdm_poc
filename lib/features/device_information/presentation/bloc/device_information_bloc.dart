import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/device_information.dart';
import '../../domain/usecases/get_device_information_use_case.dart';

part 'device_information_event.dart';
part 'device_information_state.dart';

class DeviceInformationBloc
    extends Bloc<DeviceInformationEvent, DeviceInformationState> {
  DeviceInformationBloc(this._getDeviceInformation)
    : super(const DeviceInformationState()) {
    on<DeviceInformationRequested>(_onRequested);
    on<DeviceInformationRefreshed>(_onRefreshed);
  }

  final GetDeviceInformationUseCase _getDeviceInformation;

  Future<void> _onRequested(
    DeviceInformationRequested event,
    Emitter<DeviceInformationState> emit,
  ) async {
    emit(const DeviceInformationState(status: DeviceInformationStatus.loading));
    emit(_resolve(await _getDeviceInformation()));
  }

  Future<void> _onRefreshed(
    DeviceInformationRefreshed event,
    Emitter<DeviceInformationState> emit,
  ) async {
    if (state.isRefreshing || state.status == DeviceInformationStatus.loading) {
      return;
    }
    final previous = state.information;
    emit(
      DeviceInformationState(
        status: previous == null
            ? DeviceInformationStatus.loading
            : DeviceInformationStatus.success,
        information: previous,
        isRefreshing: previous != null,
      ),
    );
    emit(_resolve(await _getDeviceInformation()));
  }

  /// A failed refresh never keeps stale data on screen as if it were current.
  static DeviceInformationState _resolve(Result<DeviceInformation> result) =>
      switch (result) {
        Success(:final value) => DeviceInformationState(
          status: DeviceInformationStatus.success,
          information: value,
        ),
        FailureResult(:final failure) => DeviceInformationState(
          status: DeviceInformationStatus.failure,
          failure: failure,
        ),
      };
}
