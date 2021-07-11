import 'api_client_error.dart';

extension JsonObjectHelper on Map<String, dynamic> {
  // ignore: avoid_init_to_null
  T? _get<T>(String key, {T? defaultValue = null}) {
    final res = this[key];

    if (res is T) {
      return res;
    }

    return defaultValue;
  }

  String? stringOrNull(String key) => _get<String>(key);

  String string(String key, {String defaultValue = ""}) => stringOrNull(key) ?? defaultValue;

  int? integerOrNull(String key) => _get<int>(key);

  int integer(String key, {int defaultValue = -1}) => integerOrNull(key) ?? defaultValue;

  double? doubleOrNull(String key) => _get<double>(key);

  double doublee(String key, {double defaultValue = -1}) => doubleOrNull(key) ?? defaultValue;

  bool? boolean(String key, {bool defaultValue = false}) => _get<bool>(key, defaultValue: false);

  DateTime? dateOrNull(String key) {
    final str = _get<String>(key);

    if (str == null || str.isEmpty) {
      return null;
    }
    try {
      return DateTime.tryParse(str);
    } catch (_) {
      return null;
    }
  }

  DateTime date(String key, {DateTime? defaultValue}) => dateOrNull(key) ?? defaultValue ?? DateTime.now();

  Map<String, dynamic>? objectOrNull(String key) => _get<Map<String, dynamic>>(key);

  Map<String, dynamic> object(String key) => objectOrNull(key) ?? {};

  T? valueOrNull<T>(String key, T selector(dynamic v)) {
    try {
      return value(key, selector);
    } catch (e) {
      return null;
    }
  }

  T value<T>(String key, T selector(dynamic v)) {
    final value = _get(key);

    if (value == null) {
      throw JsonValueNotFoundError(this, key);
    }

    return selector(value);
  }

  //non-nullable
  List<T> array<T>(String key, T selector(dynamic v)) => _get<List<dynamic>>(key, defaultValue: [])!.map((x) => selector(x)).toList(growable: false);
}

class IJsonError implements IApiClientError {
  @override
  ApiClientErrorKind get kind => ApiClientErrorKind.Json;
}

class JsonNullSourceFoundError with IJsonError {
  final String key;

  JsonNullSourceFoundError(this.key);

  @override
  String toString() => "$runtimeType: '$key' was referenced for null source.";
}

class JsonValueNotFoundError with IJsonError {
  final Map<String, dynamic> source;
  final String key;

  JsonValueNotFoundError(this.source, this.key);

  @override
  String toString() => "$runtimeType: '$key' was not found in $source";
}
