import 'package:http/http.dart';

abstract class IApiClientError implements Exception {
  ApiClientErrorKind get kind;
}

/// URIの構築に失敗した（通信前エラー）
class InvalidUriError implements IApiClientError {
  @override
  ApiClientErrorKind get kind => ApiClientErrorKind.InvalidUri;

  final String host;
  final String path;
  final Map<String, String> query;

  const InvalidUriError(this.host, this.path, this.query);

  @override
  String toString() => "$runtimeType（"
      " host = $host, "
      " path = api/$path, "
      " query = ${query?.entries?.fold<String>("", (acc, v) => "$acc, (${v.key}: ${v.value})") ?? "null"}, "
      "）";
}

/// 何らかの理由で通信リクエストを正常に行えなかった（端末側に問題のある通信エラー）
class InvalidRequestError implements IApiClientError {
  @override
  ApiClientErrorKind get kind => ApiClientErrorKind.InvalidRequest;

  final Uri uri;
  final Exception e;

  InvalidRequestError(this.uri, this.e);

  @override
  String toString() => "$runtimeType（uri = $uri, exception = $e）";
}

/// 通信がタイムアウトした
class TimeoutError implements IApiClientError {
  @override
  ApiClientErrorKind get kind => ApiClientErrorKind.Timeout;

  final Uri uri;
  final Exception e;

  const TimeoutError(this.uri, this.e);

  @override
  String toString() => "$runtimeType（uri = $uri, exception = $e）";
}

/// 200系のレスポンスが返ってこなかった
class UnsuccessfulStatusError implements IApiClientError {
  @override
  ApiClientErrorKind get kind => ApiClientErrorKind.UnsuccessfulStatus;

  final Response response;

  const UnsuccessfulStatusError(this.response);

  @override
  String toString() {
    final url = response?.request?.url;
    final status = response?.statusCode?.toString() ?? null;
    final body = response != null && response.headers["Content-Type"] == "application/json" //
        ? response.body
        : null;

    return "$runtimeType（uri = $url, code = ${status}, body = $body）";
  }
}

/// リクエストを送る前にHttpClientがclosed状態だった
class ClientClosedError implements IApiClientError {
  @override
  ApiClientErrorKind get kind => ApiClientErrorKind.ClientClosed;
  const ClientClosedError();
}

/// 想定外のエラー
class UnknownError implements IApiClientError {
  final dynamic e;

  const UnknownError(this.e);

  @override
  String toString() => "$runtimeType（type = ${e?.runtimeType ?? "null"}, message = ${e?.toString() ?? "null"}）";

  @override
  ApiClientErrorKind get kind => ApiClientErrorKind.Unknown;
}

enum ApiClientErrorKind {
  None,
  InvalidUri,
  InvalidRequest,
  Timeout,
  UnsuccessfulStatus,
  ClientClosed,
  Json,
  Unknown,
}

mixin RepositoryErrorMixin implements Exception {
  IApiClientError get error;

  @override
  String toString() => "$runtimeType by ($error)";
}
