part of 'refresh_controller.dart';

class PageRefreshController<V extends IPagiable<V>, E extends Object> extends RefreshController<V, E> {
  int? _currentPageInstance;
  int defaultPage;

  int get currentPage => _currentPageInstance ?? defaultPage;
  set currentPage(value) => _currentPageInstance = value;

  int get nextPage => _currentPageInstance?.let((x) => x + 1) ?? defaultPage;

  Future<V> Function(int page) refresher;

  PageRefreshController({
    required this.refresher,
    Duration? lifetime,
    RefreshState<V, E>? initialState,
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
      yield currentState = currentState.copyWithIsRefreshingTrue();
    }

    try {
      V newValue;

      if (config.stack) {
        // config.stackが指定されている = 1回以上Refreshが成功していて、次のページをリクエストしている
        // ignore: avoid-non-null-assertion
        final currentValue = currentState.value!;

        final value = await refresher(nextPage);
        newValue = currentValue.merge(value);
      } else {
        newValue = await refresher(nextPage);
      }

      yield currentState = currentState.copyWithSuccessValue(newValue);

      // ページングに成功したのでページ番号を更新する
      currentPage = nextPage;
    } on E catch (e, st) {
      yield currentState = currentState.copyWithError(e);

      if (RefreshController.notifyErrorEvenExpected) {
        RefreshController.errorCallback?.call(e, st);
      }
    } catch (e, st) {
      RefreshController.errorCallback?.call(e, st);
    }
  }
}
