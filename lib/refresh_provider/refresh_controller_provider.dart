import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/all.dart';

import 'controller/refresh_controller.dart';

/// [RefreshController] を生成するメソッド
///
/// 型を毎回記述するのが面倒だった
StateNotifierProvider<RefreshController<V, E>> refreshControllerProvider<V, E>({
  @required RefreshController<V, E> Function(ProviderReference ref) create,
}) {
  return StateNotifierProvider<RefreshController<V, E>>(
    (ref) => create(ref),
  );
}
