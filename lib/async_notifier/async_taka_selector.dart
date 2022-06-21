import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'async_state.dart';

typedef _OnDataCallback<T> = Widget Function(T data);
typedef _OnErrorCallback<T> = Widget Function(Object error);
typedef _OnLoadingCallback<T> = Widget Function();

class AsyncTakaSelector<T> extends HookConsumerWidget {
  /// デフォルトのローディング表示用Widget
  /// 同じ設定を何度もコンストラクタで渡すのが面倒なので、static変数で1つだけ用意する
  static Widget Function() defaultOnLoading = () => const CircularProgressIndicator();

  final ProviderListenable<AsyncState<T>> provider;
  final _OnDataCallback<T> onData;
  final _OnErrorCallback? onError;
  final _OnLoadingCallback? onLoading;
  final bool disableLoading;

  const AsyncTakaSelector({
    required this.provider,
    required this.onData,
    this.onError,
    this.onLoading,
    this.disableLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _onError = onError;
    final _onLoading = onLoading;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        _Error(
          selector: (ref) => ref.watch(provider.select((x) => x.error)),
          onError: _onError ?? (_) => const SizedBox.shrink(),
        ),
        _Data<T>(
          selector: (ref) => ref.watch(provider.select((x) => x.data)),
          onData: onData,
        ),
        if (!disableLoading) //
          _Loading(
            selector: (ref) => ref.watch(provider.select((x) => x.isLoading)),
            onLoading: _onLoading ?? defaultOnLoading,
          ),
      ],
    );
  }
}

class _Data<T> extends HookConsumerWidget {
  final T? Function(WidgetRef ref) selector;
  final _OnDataCallback<T> onData;

  const _Data({
    required this.selector,
    required this.onData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = selector(ref);

    if (data != null) {
      return onData(data);
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _Error extends HookConsumerWidget {
  final Object? Function(WidgetRef ref) selector;
  final _OnErrorCallback onError;

  const _Error({
    required this.selector,
    required this.onError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = selector(ref);

    if (error != null) {
      return onError(error);
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _Loading extends HookConsumerWidget {
  final bool Function(WidgetRef ref) selector;
  final _OnLoadingCallback onLoading;

  const _Loading({
    required this.selector,
    required this.onLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = selector(ref);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isLoading ? 1 : 0,
      child: onLoading(),
    );
  }
}
