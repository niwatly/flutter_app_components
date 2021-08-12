part of 'refresh_controller.dart';

class CursorRefreshController<C, V extends ICursorable<V, C>, E extends Object> extends RefreshController<V, E> {
  Future<V> Function(C? cursor) refresher;
  C? initialCursor;

  CursorRefreshController({
    required this.refresher,
    Duration? lifetime,
    this.initialCursor,
    RefreshState<V, E>? initialState,
  }) : super._(
          lifetime: lifetime,
          initialState: initialState,
        );

  @override
  Stream<RefreshState<V, E>> _doRefresh(RefreshConfig config, RefreshState<V, E> currentState) async* {
    if (!config.silent) {
      yield currentState = currentState.copyWith(isRefreshing: true);
    }

    try {
      V newValue;

      if (config.stack) {
        // config.stackが指定されている = 1回以上Refreshが成功していて、次のページをリクエストしている
        // ignore: avoid-non-null-assertion
        final currentValue = currentState.value!;

        final value = await refresher(currentValue.cursor);
        newValue = currentValue.merge(value);
      } else {
        newValue = await refresher(initialCursor);
      }

      yield currentState = currentState.copyWith(
        value: newValue,
        isRefreshing: false,
        initialRefreshCompleted: true,
        lastRefreshedAt: DateTime.now(),
      );
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
