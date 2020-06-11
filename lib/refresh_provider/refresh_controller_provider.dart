import 'refresh_provider.dart';

/// [RefreshController] を生成するメソッド
///
/// 型を毎回記述するのが面倒だった
StateNotifierProvider refreshControllerProvider<V, E>({
  @required RefreshController<V, E> Function(BuildContext context) create,
}) {
  return StateNotifierProvider<RefreshController<V, E>, RefreshState<V, E>>(
    create: (context) => create(context),
  );
}
