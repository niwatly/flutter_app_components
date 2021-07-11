import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'api_client.dart';
import 'api_client_error.dart';

class DefaultApiClient with IApiClient {
  static Function(int statusCode, Uri uri)? onResponseReceived;

  final bool useHttp;
  final String host;
  final int? port;
  final FutureOr<Map<String, String>>? headersFuture;
  Map<String, String>? _headers;

  late Client _client;
  late UriBuilder _uriBuilder;

  DefaultApiClient({
    this.useHttp = true,
    required this.host,
    this.port,
    this.headersFuture,
  }) {
    _client = Client();
    _uriBuilder = (path, query) {
      try {
        return Uri(
          scheme: useHttp ? "http" : "https",
          host: host,
          path: path,
          port: port,
          queryParameters: query,
        );
      } on FormatException catch (_) {
        //URIの組み立てに失敗した
        return throw InvalidUriError(host, path, query);
      }
    };
  }

  Future<Response> _sendRequest(BaseRequest request) async {
    try {
      final response = await Response.fromStream(await _client.send(request));

      onResponseReceived?.call(response.statusCode, request.url);

      if (response.statusCode < 200 || 300 <= response.statusCode) {
        //200が返ってこなかった
        return Future.error(UnsuccessfulStatusError(response));
      }

      return response;
    } on SocketException catch (e) {
      // 無効なURIが指定された
      throw InvalidRequestError(request.url, e);
    } on TimeoutException catch (e) {
      // 時間内に応答が帰ってこなかった
      throw TimeoutError(request.url, e);
    } catch (e) {
      throw UnknownError(e);
    }
  }

  Future<BaseRequest> _createBaseRequest(String method, Uri uri, {Map<String, dynamic>? body}) async {
    final headers = (_headers ??= await headersFuture)!;

    return Request(method, uri)
      ..encoding = const Utf8Codec()
      ..headers['content-type'] = 'application/json'
      ..body = body != null ? jsonEncode(body) : "{}"
      ..headers.addAll(headers);
  }

  @override
  Future<Response> post(
    String path, {
    Map<String, dynamic> query = const {},
    Map<String, dynamic> body = const {},
  }) async {
    final request = await _createBaseRequest("POST", _uriBuilder(path, query), body: body);

    return _sendRequest(request);
  }

  @override
  Future<Response> put(
    String path, {
    Map<String, dynamic> query = const {},
    Map<String, dynamic> body = const {},
  }) async {
    final request = await _createBaseRequest("PUT", _uriBuilder(path, query), body: body);

    return _sendRequest(request);
  }

  @override
  Future<Response> delete(
    String path, {
    Map<String, dynamic> query = const {},
    Map<String, dynamic> body = const {},
  }) async {
    final request = await _createBaseRequest("DELETE", _uriBuilder(path, query), body: body);

    return _sendRequest(request);
  }

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic> query = const {},
  }) async {
    final request = await _createBaseRequest("GET", _uriBuilder(path, query));

    return _sendRequest(request);
  }

  @override
  Future<Response> patch(
    String path, {
    Map<String, dynamic> query = const {},
    Map<String, dynamic> body = const {},
  }) async {
    final request = await _createBaseRequest("PATCH", _uriBuilder(path, query));

    return _sendRequest(request);
  }

  @override
  void close() {
    _client.close();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DefaultApiClient && runtimeType == other.runtimeType && useHttp == other.useHttp && host == other.host && port == other.port && _headers == other._headers;

  @override
  int get hashCode => useHttp.hashCode ^ host.hashCode ^ port.hashCode ^ _headers.hashCode;
}
