part of 'refresh_controller.dart';

class PageRefreshController<V extends IPagiable<V>, E> extends RefreshController<V, E> {
  int _currentPageInstance;
  int defaultPage;

  int get currentPage => _currentPageInstance ?? defaultPage;
  set currentPage(value) => _currentPageInstance = value;

  int get nextPage => _currentPageInstance != null ? _currentPageInstance + 1 : defaultPage;

  Future<V> Function(int page) refresher;

  PageRefreshController({
    @required this.refresher,
    Duration lifetime,
    RefreshState<V, E> initialState,
    this.defaultPage = 1,
  }) : super._(
          lifetime: lifetime,
          initialState: initialState,
        );

  @override
  Stream<RefreshState<V, E>> _doRefresh(RefreshConfig config, RefreshState<V, E> currentState) async* {
    if (!config.stack) {
      // 追加のRefreshでないときはページ番号をリセットする
      currentPage = null;
    }

    if (!config.silent) {
      yield currentState = currentState.copyWith(isRefreshing: true);
    }

    try {
      var value = await refresher(nextPage);

      if (config.stack) {
        value = currentState.value.merge(value);
      }

      yield currentState = currentState.copyWith(
        value: value,
        isRefreshing: false,
        initialRefreshCompleted: true,
        lastRefreshedAt: DateTime.now(),
      );

      // ページングに成功したのでページ番号を更新する
      currentPage = nextPage;
    } on E catch (e, st) {
      yield currentState = currentState.copyWith(
        error: e,
        isRefreshing: false,
      );

      if (RefreshController.notifyErrorEvenExpected) {
        RefreshController.errorCallback?.call(e, st);
      }
    } catch (e, st) {
      RefreshController.errorCallback?.call(e, st);
    }
  }
}
