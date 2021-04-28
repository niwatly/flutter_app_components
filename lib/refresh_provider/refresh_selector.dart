import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller/refresh_controller.dart';
import 'refresh_state.dart';

/// [RefreshState] を3つ状態に分けて、状態ごとにUIを出し分ける
///
/// また、[RefreshSelector.onValue]で与えられたWidgetは[RefreshState.isSuccess]のときにしかBuildしない。これにより、無駄なnullチェックを省略できる
class RefreshSelector<V, E> extends StatelessWidget {
  /// デフォルトのローディング表示用Widget
  /// 同じ設定を何度もコンストラクタで渡すのが面倒なので、static変数で1つだけ用意する
  static Widget Function(BuildContext context) defaultOnLoading = (context) => const CircularProgressIndicator();

  /// [RefreshState.isSuccess]時のWidgetのBuilder
  final Widget Function(BuildContext context, V value) onValue;

  /// [RefreshState.hasError]時のWidgetのBuilder
  final Widget Function(BuildContext context, E error)? onError;

  /// [RefreshState.isRefreshing]中のWidgetのBuilder
  final Widget Function(BuildContext context)? onLoading;

  /// 下位Widgetを[RefreshIndicator]でラップするかどうか
  /// [RefreshIndicator.onRefresh]の設定値が冗長になりがちなので、そこの記述量を抑えたい
  final bool enablePullRefresh;

  /// ローディング表示をしない
  ///
  /// 次のようなユースケースで便利
  /// - e.g. 通信が完了するまでWidgetを隠したい。別の箇所でもRefreshSelectorを使っていて、ローディング表示はそちらで行うので、こちらのローディング表示は不要である
  final bool disableLoading;

  /// [onValue]と[onError]と[onLoading]をStackで重ねるときのfitパラメータ
  final StackFit fit;

  final StateNotifierProvider<RefreshController<V, E>, RefreshState<V, E>> refreshControllerProvider;

  const RefreshSelector({
    required this.onValue,
    required this.refreshControllerProvider,
    this.onError,
    this.onLoading,
    this.enablePullRefresh = false,
    this.disableLoading = false,
    this.fit = StackFit.passthrough,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, T Function<T>(ProviderBase<Object, T>) watch, Widget? child) {
        Widget ret = Stack(
          fit: fit,
          children: [
            Consumer(
              builder: (context, watch, child) {
                final state = watch(refreshControllerProvider);
                final errorValue = state.value == null ? state.error : null;
                return errorValue != null && onError != null ? onError!(context, errorValue) : const SizedBox(width: 0, height: 0);
              } as Widget Function(BuildContext, T Function<T>(ProviderBase<Object?, T>), Widget?),
            ),
            Consumer(
              builder: (context, watch, child) {
                final state = watch(refreshControllerProvider);
                final value = state.value;
                return value != null ? onValue(context, value) : const SizedBox(width: 0, height: 0);
              } as Widget Function(BuildContext, T Function<T>(ProviderBase<Object?, T>), Widget?),
            ),
            if (!disableLoading)
              Consumer(
                builder: (BuildContext context, T Function<T>(ProviderBase<Object, T>) watch, Widget? child) {
                  final state = watch(refreshControllerProvider);
                  final isRefreshing = state.isRefreshing;
                  final child = onLoading != null ? onLoading!(context) : defaultOnLoading(context);
                  return AnimatedOpacity(
                    opacity: isRefreshing ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: TickerMode(
                      enabled: isRefreshing,
                      child: child,
                    ),
                  );
                },
              ),
          ],
        );

        if (enablePullRefresh) {
          ret = _Refresh<V?, E?>(ret, watch<RefreshController>(refreshControllerProvider.notifier) as RefreshController<V?, E?>);
        }
        return ret;
      },
    );
  }
}

class _Refresh<V, E> extends StatelessWidget {
  final Widget child;
  final RefreshController<V, E> controller;

  const _Refresh(this.child, this.controller);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.requestCleanRefresh(silent: true),
      child: child,
    );
  }
}
