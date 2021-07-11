import 'package:flutter/foundation.dart';

import 'inapp_router.dart';
import 'screen_arguments.dart';

class InAppLauncher {
  static Function(dynamic e, StackTrace st)? errorCallback;

  final InAppRouter router;
  final List<RegExp> blackListForUnknownUri;

  const InAppLauncher(this.router, {this.blackListForUnknownUri = const []});

  Future<InAppLaunchResult> handleUri({
    required Uri uri,
    bool disableInAppNavigation = false,
  }) async {
    if (uri.scheme == "http" || uri.scheme == "https") {
      if (router.enableDeepLinkNavigation && uri.host == router.deepLinkHost) {
        // FirebaseDynamicLinkから受け取ったDeepLinkがここにくる
        //
        // PathをCustomUrlSchemeとして処理し、アプリ内遷移する
        // アプリ内遷移に失敗した場合、ブラウザによる遷移を試みる
        if (disableInAppNavigation) {
          return InAppLaunchResult.error();
        } else {
          final args = await router.handleUri(uri);

          if (args is SilentScreenArguments) {
            // 追加で画面を開く必要がない
            // ブラウザで開く必要もないので、何もしない
            return InAppLaunchResult.silent();
          } else if (args.isNotFound) {
            // アプリ内遷移可能なURIではなかったのでブラウザで開く
            return InAppLaunchResult.browser(uri);
          } else {
            // アプリ内遷移する
            return InAppLaunchResult.screen(args);
          }
        }
      } else {
        // 通常のhttpリンクがここにくる
        //
        // アプリ外遷移する（任意のhttpリンクをブラウザで開く）
        return InAppLaunchResult.browser(uri);
      }
    } else if (router.enableInAppNavigation && uri.scheme == router.customUrlScheme) {
      // CustomUrlSchemeがここにくる
      //
      // Host+PathをCustomUrlSchemeとして処理し、アプリ内遷移する
      // Note: セキュリティ的な観点から、一部のUIではURIによるアプリ遷移を禁止することができる
      if (disableInAppNavigation) {
        return InAppLaunchResult.error();
      } else {
        final args = await router.handleUri(uri);

        if (args is SilentScreenArguments) {
          // 追加で画面を開く必要がない
          // ブラウザで開く必要もないので、何もしない
          return InAppLaunchResult.silent();
        } else if (args.isNotFound) {
          // アプリ内遷移可能なURIではなかったのでエラー
          return InAppLaunchResult.error();
        } else {
          // アプリ内遷移する
          return InAppLaunchResult.screen(args);
        }
      }
    } else {
      for (final e in blackListForUnknownUri) {
        if (e.hasMatch(uri.toString())) {
          return InAppLaunchResult.silent();
        }
      }
      // 外部アプリ起動のためのCustomUrlSchemeがここにくる（GoogleMapの起動等）
      //
      // アプリ外遷移する（任意のhttpリンクをブラウザで開く）
      return InAppLaunchResult.browser(uri);
    }
  }
}

class InAppLaunchResult {
  final IScreenArguments? screenArguments;
  final Uri? browserUri;
  final InAppLaunchResultKind? kind;

  InAppLaunchResult({
    this.browserUri,
    this.screenArguments,
    this.kind,
  });

  InAppLaunchResult.screen(IScreenArguments arguments)
      : this(
          screenArguments: arguments,
          kind: InAppLaunchResultKind.ShowScreen,
        );

  InAppLaunchResult.browser(Uri uri)
      : this(
          browserUri: uri,
          kind: InAppLaunchResultKind.OpenBrowser,
        );

  InAppLaunchResult.error()
      : this(
          kind: InAppLaunchResultKind.Error,
        );

  InAppLaunchResult.silent()
      : this(
          kind: InAppLaunchResultKind.Silent,
        );
}

enum InAppLaunchResultKind {
  ShowScreen,
  OpenBrowser,
  Error,
  Silent,
}
