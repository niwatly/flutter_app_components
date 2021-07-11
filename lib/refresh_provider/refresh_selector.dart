import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

import 'controller/refresh_controller.dart';
import 'refresh_state.dart';

/// [RefreshState] を3つ状態に分けて、状態ごとにUIを出し分ける
///
/// また、[RefreshSelector.onValue]で与えられたWidgetは[RefreshState.isSuccess]のときにしかBuildしない。これにより、無駄なnullチェックを省略できる
class RefreshSelector<V extends Object, E extends Object> extends StatelessWidget {
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

  /// [RefreshController] の生成方法
  ///
  /// 指定されなかった場合は、すでに上位で[RefreshController]が宣言されていると仮定し、[StateNotifierProvider]の宣言をSkipする
  final RefreshController<V, E> Function(BuildContext context)? controller;

  const RefreshSelector({
    required this.onValue,
    this.onError,
    this.onLoading,
    this.controller,
    this.enablePullRefresh = false,
    this.disableLoading = false,
    this.fit = StackFit.passthrough,
  });

  @override
  Widget build(BuildContext context) {
    Widget ret = Stack(
      fit: fit,
      children: [
        Selector<RefreshState<V, E>, E?>(
          selector: (context, x) => x.value == null ? x.error : null,
          builder: (context, value, child) {
            final _onError = onError;

            return value != null && _onError != null ? _onError(context, value) : const SizedBox(width: 0, height: 0);
          },
        ),
        Selector<RefreshState<V, E>, V?>(
          selector: (context, x) => x.value,
          builder: (context, value, child) => value != null ? onValue(context, value) : const SizedBox(width: 0, height: 0),
        ),
        if (!disableLoading)
          Selector<RefreshState<V, E>, bool>(
            selector: (context, x) => x.isRefreshing,
            builder: (context, value, child) {
              final _onLoading = onLoading;

              return AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: value ? 1 : 0,
                child: _onLoading != null ? _onLoading(context) : defaultOnLoading(context),
              );
            },
          ),
      ],
    );

    if (enablePullRefresh) {
      ret = _Refresh<V, E>(ret);
    }

    final _controller = controller;

    if (_controller != null) {
      ret = StateNotifierProvider<RefreshController<V, E>, RefreshState<V, E>>.value(
        value: _controller(context),
        child: ret,
      );
    }

    return ret;
  }
}

class _Refresh<V extends Object, E extends Object> extends StatelessWidget {
  final Widget child;

  const _Refresh(this.child);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<RefreshController<V, E>>().requestCleanRefresh(silent: true),
      child: child,
    );
  }
}
