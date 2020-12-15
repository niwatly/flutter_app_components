import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef PaginationCallback = Future Function();
typedef NotificationReceivedCallback = void Function(ScrollNotification notification);

class PaginationIndicator extends StatelessWidget {
  /// デフォルトのローディング表示用Widget
  /// 同じ設定を何度もコンストラクタで渡すのが面倒なので、static変数で1つだけ用意する
  static Widget Function(BuildContext context) defaultOnLoading = (context) => const CircularProgressIndicator();

  final PaginationCallback onPagination;
  final NotificationReceivedCallback onNotificationReceived;
  final Widget child;
  final bool hasMore;
  final bool reverse;

  const PaginationIndicator({
    Key key,
    @required this.onPagination,
    @required this.hasMore,
    @required this.child,
    this.onNotificationReceived,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_Notifier>(
      create: (context) => _Notifier(),
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              onNotificationReceived?.call(notification);

              final notifier = context.read<_Notifier>();
              final needLoad = notifier.checkNeedLoad(notification, hasMore);

              if (needLoad) {
                notifier.igniteAndWaitUntilFinished(onPagination);
              }
              return needLoad;
            },
            child: this.child,
          ),
          Positioned(
            bottom: reverse ? null : 0,
            top: reverse ? 0 : null,
            child: Selector<_Notifier, bool>(
              selector: (context, x) => x.value == _State.Loading,
              builder: (context, value, child) {
                if (value) {
                  return defaultOnLoading(context);
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Notifier extends ValueNotifier<_State> {
  bool disposed = false;

  _Notifier() : super(_State.Idle);

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  checkNeedLoad(ScrollNotification notification, bool hasMore) {
    final metrics = notification.metrics;

//    logger.info("""
//
//                    state: $value
//                    maxScrollExtent: ${metrics.maxScrollExtent}
//                    pixels: ${metrics.pixels}
//                    extentBefore: ${metrics.extentBefore}
//                    extentAfter: ${metrics.extentAfter}
//                    outOfRange: ${metrics.outOfRange}
//                    axis: ${metrics.axis}
//                    axisDirection: ${metrics.axisDirection}
//                    """);

    if (!hasMore) {
      return false;
    }

    if (value == _State.Loading) {
      return false;
    }

    if (metrics.extentAfter > 150 || metrics.extentBefore == 0.0) {
      return false;
    }

    return true;
  }

  Future igniteAndWaitUntilFinished(Future Function() onPagination) async {
    if (disposed) {
      return;
    }

    value = _State.Loading;
    notifyListeners();

    try {
      await onPagination();
    } catch (_) {
      //ignore
    }

    // 問題: 次ページの読み込みが終わってから、リストがbuildされてmaxScrollExtentが更新されるまでの間、
    //     : 次ページを読み込む必要がないのに読み込み判定が行われてしまう時間が存在する
    //     : この間を無視しないと、3ページ目を読み込んだ直後に4ページ目も読み込まれてしまう
    // 対応: 少し待つ
    await Future.delayed(const Duration(milliseconds: 200));

    if (disposed) {
      return;
    }
    value = _State.Idle;
    notifyListeners();
  }
}

enum _State {
  Idle,
  Loading,
}
