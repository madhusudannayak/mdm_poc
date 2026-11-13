part of 'provisioning_bloc.dart';

sealed class ProvisioningBlocState extends Equatable {
  const ProvisioningBlocState();

  @override
  List<Object?> get props => [];
}

final class ProvisioningInitial extends ProvisioningBlocState {
  const ProvisioningInitial();
}

final class ProvisioningLoading extends ProvisioningBlocState {
  const ProvisioningLoading();
}

final class ProvisioningLoaded extends ProvisioningBlocState {
  const ProvisioningLoaded(this.status);

  final ProvisioningStatus status;

  @override
  List<Object?> get props => [status];
}

final class ProvisioningLoadFailure extends ProvisioningBlocState {
  const ProvisioningLoadFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
