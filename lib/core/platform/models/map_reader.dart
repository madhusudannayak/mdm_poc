import '../../errors/mdm_exceptions.dart';

/// Strictly typed access to the loosely typed maps delivered by the platform
/// channel codec. Every mismatch becomes an [MdmException] with
/// `INVALID_RESPONSE` instead of a runtime type error.
class MapReader {
  MapReader(Object? source, {this.context = 'response'})
    : _map = _toStringMap(source, context);

  final String context;
  final Map<String, Object?> _map;

  static Map<String, Object?> _toStringMap(Object? source, String context) {
    if (source is! Map) {
      throw MdmException.invalidResponse(
        'Expected a map for $context but received ${source.runtimeType}.',
      );
    }
    return source.map((key, value) => MapEntry(key.toString(), value));
  }

  /// Converts a channel list payload into a list of typed items.
  static List<T> list<T>(
    Object? source,
    T Function(Object? item) convert, {
    String context = 'response',
  }) {
    if (source is! List) {
      throw MdmException.invalidResponse(
        'Expected a list for $context but received ${source.runtimeType}.',
      );
    }
    return List<T>.unmodifiable(source.map(convert));
  }

  T _required<T>(String key) {
    final value = _map[key];
    if (value is T) return value;
    throw MdmException.invalidResponse(
      'Field "$key" of $context has type ${value.runtimeType}, expected $T.',
    );
  }

  T? _optional<T>(String key) {
    final value = _map[key];
    if (value == null) return null;
    if (value is T) return value as T;
    throw MdmException.invalidResponse(
      'Field "$key" of $context has type ${value.runtimeType}, expected $T.',
    );
  }

  String string(String key) => _required<String>(key);
  String? stringOrNull(String key) => _optional<String>(key);
  int integer(String key) => _required<int>(key);
  int? integerOrNull(String key) => _optional<int>(key);
  bool boolean(String key) => _required<bool>(key);
  bool? booleanOrNull(String key) => _optional<bool>(key);
  Object? raw(String key) => _map[key];

  List<String> stringList(String key) => list<String>(
    _map[key] ?? const <Object?>[],
    (item) => item.toString(),
    context: '$context.$key',
  );

  List<int> intList(String key) =>
      list<int>(_map[key] ?? const <Object?>[], (item) {
        if (item is int) return item;
        throw MdmException.invalidResponse(
          'Field "$key" of $context contains a non-integer item.',
        );
      }, context: '$context.$key');

  Map<String, bool> boolMap(String key) {
    final value = _map[key];
    if (value == null) return const {};
    if (value is! Map) {
      throw MdmException.invalidResponse(
        'Field "$key" of $context is not a map.',
      );
    }
    return Map<String, bool>.unmodifiable(
      value.map((k, v) => MapEntry(k.toString(), v == true)),
    );
  }
}
