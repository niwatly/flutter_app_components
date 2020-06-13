import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class TraceStack extends StatelessWidget {
  final Widget baseChild;
  final List<Widget> followChildren;
  final bool isBaseChildOnBackground;
  
  const TraceStack({
    @required this.baseChild,
    this.followChildren = const [],
    this.isBaseChildOnBackground = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      ...followChildren.map(
            (x) => _FollowingChild(
          child: x,
        ),
      ),
    ];
    
    final base = _BaseChild(
      child: baseChild,
    );
    
    if (isBaseChildOnBackground) {
      children.insert(0, base);
    } else {
      children.add(base);
    }
    
    return ChangeNotifierProvider<_Notifier>(
      create: (context) => _Notifier(),
      child: Stack(
        children: children,
      ),
    );
  }
}

class _FollowingChild extends SingleChildStatelessWidget {
  const _FollowingChild({Widget child}) : super(child: child);
  
  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    final notifier = Provider.of<_Notifier>(context);
    
    return SizedBox(
      width: notifier.value.width,
      height: notifier.value.height,
      child: child,
    );
  }
}

class _BaseChild extends SingleChildRenderObjectWidget {
  const _BaseChild({Widget child}) : super(child: child);
  
  @override
  RenderObject createRenderObject(BuildContext context) => _BaseChildRenderObject(
    Provider.of<_Notifier>(context),
  );
}

class _BaseChildRenderObject extends RenderProxyBox {
  final _Notifier _notifier;
  
  _BaseChildRenderObject(this._notifier);
  
  @override
  void performLayout() {
    super.performLayout();
    
    final size = this.size;
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifier.value = size);
  }
}

class _Notifier extends ValueNotifier<Size> {
  _Notifier() : super(Size.zero);
}
