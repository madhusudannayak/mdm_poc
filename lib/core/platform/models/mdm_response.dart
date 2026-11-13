import 'package:equatable/equatable.dart';

import 'map_reader.dart';

/// The standard envelope every native MDM method replies with:
///
/// ```json
/// {"success": true, "message": "...", "data": {}, "errorCode": null}
/// ```
class MdmResponse extends Equatable {
  const MdmResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  /// Parses the raw channel reply. Throws an `INVALID_RESPONSE`
  /// [MdmException] when the reply is not a valid envelope.
  factory MdmResponse.fromRaw(Object? raw, {required String method}) {
    final reader = MapReader(raw, context: '$method envelope');
    return MdmResponse(
      success: reader.boolean('success'),
      message: reader.stringOrNull('message') ?? '',
      data: reader.raw('data'),
      errorCode: reader.stringOrNull('errorCode'),
    );
  }

  final bool success;
  final String message;
  final Object? data;
  final String? errorCode;

  @override
  List<Object?> get props => [success, message, data, errorCode];
}
