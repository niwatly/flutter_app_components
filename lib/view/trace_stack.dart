import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class TraceStack extends StatelessWidget {
  final List<TraceStackChild>? children;
  final StackFit fit;
  final AlignmentGeometry alignment;
  final Clip clip;

  const TraceStack({
    this.children,
    this.clip = Clip.hardEdge,
    this.fit = StackFit.loose,
    this.alignment = AlignmentDirectional.topStart,
  });

  @override
  Widget build(BuildContext context) {
    assert(children!.any((x) => x.isBaseSizeChild));

    return ChangeNotifierProvider<_Notifier>(
      create: (context) => _Notifier(),
      child: Stack(
        fit: fit,
        alignment: alignment,
        clipBehavior: clip,
        children: children!,
      ),
    );
  }
}

class TraceStackChild extends StatelessWidget {
  final Widget? child;
  final bool isBaseSizeChild;

  const TraceStackChild({
    this.child,
    this.isBaseSizeChild = false,
  });

  const TraceStackChild.base({
    this.child,
  }) : isBaseSizeChild = true;

  const TraceStackChild.follow({
    this.child,
  }) : isBaseSizeChild = false;

  @override
  Widget build(BuildContext context) {
    return isBaseSizeChild ? _BaseChild(child: child) : _FollowChild(child: child);
  }
}

class _FollowChild extends StatelessWidget {
  final Widget? child;

  const _FollowChild({this.child});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<_Notifier>(context);

    return SizedBox(
      width: notifier.value.width,
      height: notifier.value.height,
      child: child,
    );
  }
}

class _BaseChild extends SingleChildRenderObjectWidget {
  const _BaseChild({Widget? child}) : super(child: child);

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

    WidgetsBinding.instance!.addPostFrameCallback((_) => _notifier.value = size);
  }
}

class _Notifier extends ValueNotifier<Size> {
  bool disposed = false;

  _Notifier() : super(Size.zero);

  @override
  set value(Size newValue) {
    if (disposed) {
      return;
    }

    super.value = newValue;
  }

  @override
  void dispose() {
    super.dispose();
    disposed = true;
  }
}
