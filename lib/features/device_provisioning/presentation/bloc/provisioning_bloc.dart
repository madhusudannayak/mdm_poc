import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/provisioning_status.dart';
import '../../domain/usecases/get_provisioning_status_use_case.dart';

part 'provisioning_event.dart';
part 'provisioning_state.dart';

class ProvisioningBloc extends Bloc<ProvisioningEvent, ProvisioningBlocState> {
  ProvisioningBloc(this._getProvisioningStatus)
    : super(const ProvisioningInitial()) {
    on<ProvisioningStatusRequested>(_onRequested);
  }

  final GetProvisioningStatusUseCase _getProvisioningStatus;

  Future<void> _onRequested(
    ProvisioningStatusRequested event,
    Emitter<ProvisioningBlocState> emit,
  ) async {
    if (state is ProvisioningLoading) return;
    emit(const ProvisioningLoading());
    emit(switch (await _getProvisioningStatus()) {
      Success(:final value) => ProvisioningLoaded(value),
      FailureResult(:final failure) => ProvisioningLoadFailure(failure),
    });
  }
}
