import '../constants/mdm_constants.dart';

/// Thrown by the platform layer when a native MDM operation cannot be
/// completed. Always carries a machine-readable [code] from [MdmErrorCodes].
class MdmException implements Exception {
  const MdmException({required this.code, required this.message});

  const MdmException.invalidArgument(this.message)
    : code = MdmErrorCodes.invalidArgument;

  const MdmException.invalidResponse(this.message)
    : code = MdmErrorCodes.invalidResponse;

  final String code;
  final String message;

  @override
  String toString() => 'MdmException($code): $message';
}
