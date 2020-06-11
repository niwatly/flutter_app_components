import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';

import 'controller/refresh_controller.dart';
import 'refresh_state.dart';

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
