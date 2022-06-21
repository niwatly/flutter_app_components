import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'async_state.dart';

export 'async_state.dart';
export 'async_taka_selector.dart';

typedef _AsyncNotifierFuture<T> = Future<T> Function();

class AsyncNotifier<T> extends StateNotifier<AsyncState<T>> {
  AsyncNotifier({
    required Reader read,
    required _AsyncNotifierFuture<T> future,
    bool requestOnInitialize = false,
  })  : _read = read,
        _future = future,
        super(AsyncState()) {
    if (requestOnInitialize) {
      request();
    }
  }

  // ignore: unused_field
  final Reader _read;
  final _AsyncNotifierFuture<T> _future;

  Future request() async {
    try {
      state = state.copyWith(isLoading: true);
      final res = await _future();

      // NOTE: error を null で上書きしたいのでcopyWithは使っていない
      state = AsyncState(
        data: res,
        error: null,
        lastLoadTime: DateTime.now(),
        isLoading: false,
        initialLoadCompleted: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: e,
        isLoading: false,
      );
    }
  }

  void replace(T data) {
    if (state.data == null) {
      throw Exception("想定外のユースケースです");
    }

    state = state.copyWith(
      data: data,
    );
  }

  @override
  void dispose() {
    super.dispose();
    print("$runtimeType disposed.");
  }
}
