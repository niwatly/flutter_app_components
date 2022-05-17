import 'package:flutter/material.dart';
import 'package:flutter_app_components/utility/no_grow_scroll_configuration.dart';

import 'unfocus.dart';

/// ScrollViewの子供の高さが画面の幅に満たないとき、スクロールすると子供が不自然に見切れることを防ぐScrollView
///
/// ※ physicsをAlwaysScrollableScrollPhysicsにしなければ発生しないが、常時PullToRefresh可能な状態を実現するためにはAlwaysScrollableScrollPhysicsが必要
class ScrollableAlign extends StatelessWidget {
  final Widget? child;
  final Alignment alignment;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final bool showScrollBar;
  final bool unfocusWhenScrollStarted;
  final bool unfocusWhenTapped;
  final bool disableGrowEffect;
  final bool reverse;
  final bool scrollBarIsAlwaysShown;
  final ScrollPhysics? parentScrollPhysics;

  const ScrollableAlign({
    this.alignment = Alignment.topCenter,
    this.child,
    this.padding,
    this.controller,
    this.showScrollBar = false,
    this.scrollBarIsAlwaysShown = false,
    this.unfocusWhenScrollStarted = false,
    this.unfocusWhenTapped = false,
    this.disableGrowEffect = false,
    this.reverse = false,
    this.parentScrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    Widget ret = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        reverse: reverse,
        physics: AlwaysScrollableScrollPhysics(parent: parentScrollPhysics),
        controller: controller,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Align(
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );

    if (unfocusWhenScrollStarted || unfocusWhenTapped) {
      ret = Unfocus(
        child: ret,
        unfocusWhenScrollStarted: unfocusWhenScrollStarted,
        unfocusWhenTapped: unfocusWhenTapped,
      );
    }

    if (showScrollBar) {
      ret = Scrollbar(
        child: ret,
        thumbVisibility: scrollBarIsAlwaysShown,
      );
    }

    if (disableGrowEffect) {
      ret = NoGlowScrollConfiguration(
        child: ret,
      );
    }

    return ret;
  }
}
