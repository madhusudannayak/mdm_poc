import 'package:equatable/equatable.dart';

import '../constants/mdm_constants.dart';
import 'mdm_exceptions.dart';

/// Domain-level description of a failed operation, safe to show in the UI.
class Failure extends Equatable {
  const Failure({required this.code, required this.message});

  factory Failure.fromException(Object error) {
    if (error is MdmException) {
      return Failure(code: error.code, message: error.message);
    }
    return Failure(code: MdmErrorCodes.unknown, message: error.toString());
  }

  final String code;
  final String message;

  bool get isDeviceOwnerRequired => code == MdmErrorCodes.deviceOwnerRequired;
  bool get isNativeMethodMissing => code == MdmErrorCodes.nativeMethodMissing;

  @override
  List<Object?> get props => [code, message];
}
