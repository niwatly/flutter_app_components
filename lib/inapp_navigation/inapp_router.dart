import 'package:fluro/fluro.dart' hide RouteNotFoundException;
import 'package:flutter/material.dart' hide Router;

import 'screen_arguments.dart';

typedef RouteGenerator = IScreenArguments Function(Map<String, List<String>> params);

class RouteState {}

class InAppRouter {
  static Function(dynamic e, StackTrace st)? errorCallback;

  late FluroRouter _router;

  final Map<String, RouteGenerator> routeDefines;
  final String? customUrlScheme;
  final String? deepLinkHost;

  bool get enableInAppNavigation => customUrlScheme != null;
  bool get enableDeepLinkNavigation => deepLinkHost != null;

  InAppRouter({
    required this.routeDefines,
    this.customUrlScheme,
    this.deepLinkHost,
  }) {
    _router = FluroRouter.appRouter;

    final keys = routeDefines.keys.toList();

    // 背景: RouterはroutePathを与えられた順に処理する
    // 問題: /campaigns/2 と /campaigns が定義されているときに、/campaigns/2 という入力に対してどちらもヒットしてしまい、意図しない結果になることがある
    // 対応: routePathを住所順の降順に並び替えて、その順にdefineしていく
    keys.sort();

    for (final key in keys.reversed) {
      // Hanlderは使わないので何でも良い
      _router.define(key, handler: Handler(handlerFunc: (context, parameters) {}));
    }
  }

  /// 任意のURIが与えられた時、そのURIをアプリ内遷移に必要なpathに変換する
  ///
  /// e.g. instagram://home -> /home
  /// e.g. instagram:// -> /
  /// e.g. https://yahoo.co.jp/home -> /home
  /// e.g. https://yahoo.co.jp/search?query=bump -> /home?query=bump
  String? extractPathFromUri(Uri uri) {
    String? path;

    if (uri.scheme == "http" || uri.scheme == "https" && enableInAppNavigation && uri.host == deepLinkHost) {
      // Http、かつDeepLinkとして指定されているHostなら、Uriのpathをそのまま使用する
      path = uri.path;
    } else if (enableInAppNavigation && uri.scheme == customUrlScheme) {
      // customUrlScheme なら、hostより後ろをPathとして切り取る
      // host がない場合（"scheme://"）は "/" をPathとする
      if (uri.host.isEmpty) {
        path = Navigator.defaultRouteName;
      } else {
        path = uri.path.isEmpty ? uri.host : "${uri.host}${uri.path}";
      }
    }

    if (path?.isEmpty ?? true) {
      return null;
    }

    if (uri.query.isNotEmpty) {
      path = "$path?${uri.query}";
    }

    return path;
  }

  Future<IScreenArguments> handleUri(
    Uri uri,
  ) async {
    //logger.info("try handle uri $input");

    final path = extractPathFromUri(uri);

    //logger.info("extracted path $path");

    if (path == null || path.isEmpty) {
      // pathの解析に失敗したのでRouteNotFound
      // e.g. 無効な文字列
      // e.g. 無効なscheme
      errorCallback?.call(RouteNotFoundException.cannotExtractPath(uri), StackTrace.current);

      return const RouteNotFoundScreenArguments();
    }

    return handlePath(path);
  }

  Future<IScreenArguments> handlePath(String path) async {
    if (path == Navigator.defaultRouteName) {
      //背景: defaultRouteNameへの遷移がリクエストされたらアプリを立ち上げたい（開く画面は特に気にしない）
      //背景: handleUriメソッドを呼べるということは既に何かしらの画面を開いている
      //背景: RouterはdefaultRouteNameへのroutingに非対応
      //対応: defaultRouteNameがリクエストされたら何もせずに終了する

      return SilentScreenArguments();
    }

    IScreenArguments found;

    final match = _router.match(path);

    if (match == null) {
      errorCallback?.call(RouteNotFoundException.noMatch(path), StackTrace.current);
      found = const RouteNotFoundScreenArguments();
    } else {
      found = routeDefines[match.route.route]!(match.parameters);
    }

    return found;
  }
}
