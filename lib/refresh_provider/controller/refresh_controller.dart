import 'package:rxdart/rxdart.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../utility/extension.dart';
import '../refresh_config.dart';
import '../refresh_state.dart';

part 'cursor_refresh_controller.dart';
part 'page_refresh_controller.dart';
part 'offset_style_page_refresh_controller.dart';
part 'simple_refresh_controller.dart';

abstract class RefreshController<V extends Object, E extends Object> extends StateNotifier<RefreshState<V, E>> {
  static Function(dynamic e, StackTrace st)? errorCallback;
  static bool notifyErrorEvenExpected = false;

  Duration? lifetime;

  DateTime? _lastLoadTime;

  // ignore: close_sinks
  late Sink<Stream<void>> requestLifetimeRefreshSink;

  // ignore: close_sinks
  late Sink<Stream<RefreshConfig>> requestConfigRefreshSink;

  final CompositeSubscription _compositeSubscription = CompositeSubscription();

  final PublishSubject<Stream<void>> _requestLifetimeRefreshSub = PublishSubject();
  final PublishSubject<Stream<RefreshConfig>> _requestConfigRefreshSub = PublishSubject();

  RefreshController._({
    this.lifetime,
    RefreshState<V, E>? initialState,
  }) : super(initialState ?? RefreshState<V, E>()) {
    requestLifetimeRefreshSink = _requestLifetimeRefreshSub.sink;
    requestConfigRefreshSink = _requestConfigRefreshSub.sink;

    Rx.merge([
      _requestLifetimeRefreshSub.flatMap((x) => x).map((x) => RefreshConfig()),
      _requestConfigRefreshSub.flatMap((x) => x),
    ]).listen((x) => requestLifetimeRefresh(config: x)).addTo(_compositeSubscription);
  }

  @override
  void dispose() {
    _requestConfigRefreshSub.close();
    _requestLifetimeRefreshSub.close();
    _compositeSubscription.dispose();
    super.dispose();
  }

  Future requestLifetimeRefresh({RefreshConfig? config}) async {
    final conf = config ?? RefreshConfig();

    if (!_checkNeedLoad(conf)) {
      return;
    }

    try {
      await _mayRefresh(conf);
      _lastLoadTime = DateTime.now();
    } catch (e) {
      //ignore
    }
  }

  Future requestSilentRefresh() => requestCleanRefresh(silent: true);

  Future requestCleanRefresh({silent = false}) async {
    final config = RefreshConfig(silent: silent);

    return await _mayRefresh(config);
  }

  Future requestMoreRefresh() async {
    final config = RefreshConfig(silent: true, stack: true);

    return await _mayRefresh(config);
  }

  Future _mayRefresh(RefreshConfig config) async {
    await for (final newState in _doRefresh(config, state)) {
      if (!mounted) {
        break;
      }

      state = newState;
    }
  }

  /// リフレッシュの実装
  ///
  /// disposeされたStateNotifierのstateプロパティにアクセスするとエラーが返るので、実装内では触らないこと
  /// 同様に、stateプロパティを更新しようとしてもエラーがなので、更新はyieldを介して行うこと
  Stream<RefreshState<V, E>> _doRefresh(RefreshConfig config, RefreshState<V, E> currentState);

  bool _checkNeedLoad(RefreshConfig config) {
    if (state.isRefreshing) {
      // リフレッシュ命令を処理中なので更新しない
      return false;
    }

    if (config.resetLifetime) {
      // 強制ロードが要求されたので更新する
      return true;
    }

    final _lastLoad = _lastLoadTime;
    if (_lastLoad == null) {
      // まだ一度もリフレッシュしていないので更新する
      return true;
    }

    final _lifetime = lifetime;
    if (_lifetime == null) {
      // ライフタイムが指定されていないので更新する
      return true;
    }

    final now = DateTime.now();
    final diff = now.difference(_lastLoad);
    final needLoad = diff.compareTo(_lifetime) == 1;

    if (!needLoad) {
      print("Skip refresh. lifetime will be over after ${(_lifetime - diff).inSeconds} seconds.");
    }

    return needLoad;
  }
}
