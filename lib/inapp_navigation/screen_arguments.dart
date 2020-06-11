import 'package:flutter/material.dart';

import 'dialog_helper.dart';

abstract class IScreenArguments<T> {
  Route<T> generateRoute();

  /// 画面の名前
  /// 画面の一致判定や、計測イベントに使用される
  String get screenName;

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
}

/// お探しのページは見つかりませんでした
class RouteNotFoundScreenArguments implements IScreenArguments {
  const RouteNotFoundScreenArguments();

  @override
  Route generateRoute() => DialogRoute(
        settings: RouteSettings(name: screenName),
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            "エラー",
            style: Theme.of(context).textTheme.subtitle1.apply(),
          ),
          content: Text(
            "お探しのページは見つかりませんでした",
            style: Theme.of(context).textTheme.bodyText1.apply(),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: Theme.of(context).textTheme.bodyText1.apply(
                    //color: context.colors.main50,
                    ),
              ),
            ),
          ],
        ),
      );

  @override
  String get screenName => name;

  static const String name = "/404";

  @override
  bool get isSingleTask => false;

  @override
  bool get isSingleTop => false;
}

class RouteNotFoundException implements Exception {
  final String message;

  RouteNotFoundException.invalidUri(String src) : message = "Invalid uri found. $src.";

  RouteNotFoundException.cannotExtractPath(Uri src) : message = "Cannot extract path. $src";

  RouteNotFoundException.noMatch(Uri src) : message = "No routes matched. $src";

  @override
  String toString() => message;
}
