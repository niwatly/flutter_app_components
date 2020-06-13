import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'trace_stack.dart';

class LoadingCrossFade extends StatelessWidget {
  static Widget Function(BuildContext context) defaultLoadingWidget = (context) => CircularProgressIndicator();

  final bool isLoading;
  final Widget child;
  final Duration duration;
  final Widget loadingWidget;

  const LoadingCrossFade({
    @required this.isLoading,
    @required this.child,
    this.loadingWidget,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      layoutBuilder: (top, topKey, bottom, bottomKey) {
        Widget base;
        Widget following;

        if (topKey == const ValueKey(CrossFadeState.showFirst)) {
          base = top;
          following = bottom;
        } else {
          base = bottom;
          following = top;
        }
        return TraceStack(
          baseChild: base,
          followChildren: [following],
        );
      },
      crossFadeState: isLoading == true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: duration,
      firstChild: child,
      secondChild: loadingWidget ?? defaultLoadingWidget.call(context),
    );
  }
}
