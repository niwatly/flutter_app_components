part of 'refresh_controller.dart';

class CursorRefreshController<C extends Object, V extends ICursorable<V, C>, E extends Object> extends RefreshController<V, E> {
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
      final cursor = config.stack //
          ? currentState.value!.cursor
          : initialCursor;

      var value = await refresher(cursor);

      if (config.stack) {
        value = currentState.value!.merge(value);
      }

      yield currentState = currentState.copyWith(
        value: value,
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
