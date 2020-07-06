import 'dart:async';

import 'package:http/http.dart';

typedef UriBuilder = Uri Function(String path, Map<String, dynamic> query);

abstract class IApiClient {
  Future<Response> get(
    String path, {
    Map<String, dynamic> query,
  });

  Future<Response> post(
    String path, {
    Map<String, dynamic> query,
    Map<String, dynamic> body,
  });

  Future<Response> put(
    String path, {
    Map<String, dynamic> query,
    Map<String, dynamic> body,
  });

  Future<Response> delete(
    String path, {
    Map<String, dynamic> query,
    Map<String, dynamic> body,
  });

  Future<Response> patch(
    String path, {
    Map<String, dynamic> query,
    Map<String, dynamic> body,
  });

  void close();
}

String makeQueryWithSquareBlanketsArrayParameters(Map<String, dynamic /*String|Iterable<String>*/ > queryParameters) {
  if (queryParameters == null) {
    return null;
  }

  final result = StringBuffer();
  var separator = "";

  void writeParameter(String key, String value, bool array) {
    result.write(separator);
    separator = "&";
    result.write(Uri.encodeQueryComponent(key));
    if (array && !key.endsWith("[]")) {
      result.write("[]");
    }
    if (value != null && value.isNotEmpty) {
      result.write("=");
      result.write(Uri.encodeQueryComponent(value));
    }
  }

  String convertToString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is bool || value is int) {
      return value.toString();
    }

    return value;
  }

  queryParameters.forEach((key, value) {
    if (value == null) {
      return;
    }

    if (value is String || value is bool || value is int) {
      writeParameter(key, convertToString(value), false);
    } else {
      final values = value;
      for (dynamic value in values) {
        writeParameter(key, convertToString(value), true);
      }
    }
  });
  return result.toString();
}
