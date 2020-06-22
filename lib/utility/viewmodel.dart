import 'package:state_notifier/state_notifier.dart';

typedef ViewModelStateWatcher<T> = T Function(T currentState, Locator locator);

/// EntityデータとUIの仲介役となるViewModelを生成します
///
/// [ViewModel]の動作は、基本的には、StateNotifierを拡張して得られる動作と同じです。一点だけ違うのは、
/// 「Entityデータのデータソースを一意に決めることができない」という状態において、そのデータソースの定義を外部から指定することができるので、
/// 通常のStateNotifierよりも少しだけ便利です。
///
/// UIからの入力を[ViewModel]で受け取りたい場合は、継承して使用してください
class ViewModel<T> extends StateNotifier<T> with LocatorMixin {
  final ViewModelStateWatcher<T> stateWatcher;
  
  ViewModel({
    T initialState,
    this.stateWatcher,
  }) : super(initialState);
  
  @override
  void initState() {
    super.initState();
    
    _tryUpdateState(read);
  }
  
  @override
  void update(T Function<T>() watch) {
    super.update(watch);
    
    _tryUpdateState(watch);
  }
  
  void _tryUpdateState(Locator locator) {
    if (stateWatcher == null) {
      return;
    }
    
    final oldState = state;
    
    final newState = stateWatcher(state, locator);
    
    if (oldState != newState) {
      state = newState;
    }
  }
}
