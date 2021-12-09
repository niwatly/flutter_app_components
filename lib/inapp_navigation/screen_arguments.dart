import 'package:flutter/material.dart';

abstract class IScreenArguments<T> {
  Route<T> generateRoute();

  /// 画面の名前
  /// 画面の一致判定や、計測イベントに使用される
  String get screenName;

  /// 画面の名前のフォーマット
  /// パラメータだけが異なる2つの画面名を同一のもとして判定したい時に使用される
  String get screenNameFormat;

  /// このScreenが画面スタックの最上位になる時に、同じ名前のScreenのpushがリクエストされたら、
  /// pushするのではなくreplaceする
  ///
  /// 雑に言うと、できるだけ重複表示は避けたい画面かどうか
  bool get isSingleTop;

  /// このScreenが画面スタックのいずれかの位置にある時に、同じ名前のScreenのpushがリクエストされたら、
  /// スタック中の同じ名前のScreenが最上位になるまでスタックをpopしたあと、pushではなくreplaceする
  ///
  /// 雑に言うと、絶対に重複表示を避けたい画面かどうか
  bool get isSingleTask;
}

extension ScreenArgumentsEx on IScreenArguments {
  bool get isNotFound => screenName == RouteNotFoundScreenArguments.name;

  RouteSettings get settings => RouteSettings(
        name: screenName,
        arguments: this,
      );
}

/// お探しのページは見つかりませんでした
class RouteNotFoundScreenArguments implements IScreenArguments {
  static const String name = "/404";

  const RouteNotFoundScreenArguments();

  @override
  Route generateRoute() => RawDialogRoute(
        settings: RouteSettings(name: screenName),
        pageBuilder: (BuildContext buildContext, Animation<double> anim, Animation<double> secondAnim) {
          final child = Builder(
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text("エラー"),
              content: const Text("お探しのページは見つかりませんでした"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "OK",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
          );

          return child;
        },
      );

  @override
  String get screenName => screenNameFormat;

  @override
  String get screenNameFormat => name;

  @override
  bool get isSingleTask => false;

  @override
  bool get isSingleTop => false;
}

class SilentScreenArguments implements IScreenArguments {
  const SilentScreenArguments();

  @override
  Route generateRoute() {
    throw UnimplementedError();
  }

  @override
  // TODO(niwatly): implement isSingleTask
  bool get isSingleTask => throw UnimplementedError();

  @override
  bool get isSingleTop => throw UnimplementedError();

  @override
  String get screenName => throw UnimplementedError();

  @override
  String get screenNameFormat => throw UnimplementedError();
}

class RouteNotFoundException implements Exception {
  final String message;

  RouteNotFoundException.invalidUri(String uri) : message = "Invalid uri found. uri = $uri.";

  RouteNotFoundException.cannotExtractPath(Uri uri) : message = "Cannot extract path. uri = $uri";

  RouteNotFoundException.noMatch(String? path) : message = "No routes matched. path = $path";

  @override
  String toString() => message;
}
