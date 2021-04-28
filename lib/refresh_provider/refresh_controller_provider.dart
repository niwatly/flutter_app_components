import 'package:flutter_app_components/refresh_provider/refresh_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller/refresh_controller.dart';

/// [RefreshController] を生成するメソッド
///
/// 型を毎回記述するのが面倒だった
StateNotifierProvider<RefreshController<V, E>, RefreshState<V, E>>
    refreshControllerProvider<V, E>({
  required RefreshController<V, E> Function(ProviderReference ref) create,
}) {
  return StateNotifierProvider<RefreshController<V, E>, RefreshState<V, E>>(
    (ref) => create(ref),
  );
}
