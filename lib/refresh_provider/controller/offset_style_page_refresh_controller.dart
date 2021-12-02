part of 'refresh_controller.dart';

class OffsetRefreshController<V extends IOffsetable<V>, E extends Object> extends RefreshController<V, E> {
  final Future<V> Function(int offset) refresher;
  int initialOffset;

  OffsetRefreshController({
    required this.refresher,
    this.initialOffset = 0,
    Duration? lifetime,
    RefreshState<V, E>? initialState,
  }) : super._(
          lifetime: lifetime,
          initialState: initialState,
        );

  @override
  Stream<RefreshState<V, E>> _doRefresh(RefreshConfig config, RefreshState<V, E> currentState) async* {
    if (!config.silent) {
      yield currentState = currentState.copyWithIsRefreshingTrue();
    }

    try {
      V newValue;

      if (config.stack) {
        // config.stackが指定されている = 1回以上Refreshが成功していて、次のページをリクエストしている
        // ignore: avoid-non-null-assertion
        final currentValue = currentState.value!;

        final value = await refresher(currentValue.offset);
        newValue = currentValue.merge(value);
      } else {
        newValue = await refresher(initialOffset);
      }

      yield currentState = currentState.copyWithSuccessValue(newValue);
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
