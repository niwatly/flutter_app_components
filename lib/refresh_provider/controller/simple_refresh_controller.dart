part of 'refresh_controller.dart';

/// [RefreshState] を State に持つ [StateNotifier]
///
/// やりたいこと
/// - API通信の無駄を抑えたい。コンテンツの寿命（lifetime）を設定して、寿命が切れていないうちは通信リクエストをSkipしたい
/// - API通信に関する各種データを管理したい
///   - 通信成功時のデータと通信失敗時のデータ
///   - ローディング中かどうか
///   - 初回ロードは完了しているかどうか
/// - 「通信を開始する」における各種interfaceを何度も書きたくない
///   - コンテンツの寿命が切れていれば通信を実行する
///   - まだ一度も通信が行われていなければ通信を実行する
///   - コンテンツの寿命を無視して通信を実行する
///   - ページングする（[PageRefreshController]を参照）
class SimpleRefreshController<V extends Object, E extends Object> extends RefreshController<V, E> {
  Future<V> Function() refresher;

  SimpleRefreshController({
    required this.refresher,
    RefreshState<V, E>? initialState,
    Duration? lifetime,
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
      final value = await refresher();

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
