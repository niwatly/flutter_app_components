import 'package:flutter/material.dart';

/// ScrollViewの子供の高さが画面の幅に満たないとき、スクロールすると子供が不自然に見切れることを防ぐScrollView
///
/// ※ physicsをAlwaysScrollableScrollPhysicsにしなければ発生しないが、常時PullToRefresh可能な状態を実現するためにはAlwaysScrollableScrollPhysicsが必要
class ScrollableAlign extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;
  final ScrollController controller;
  final bool showScrollBar;

  const ScrollableAlign({
    this.alignment = Alignment.topCenter,
    this.child,
    this.padding,
    this.controller,
    this.showScrollBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final scroll = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
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

    if (showScrollBar) {
      return Scrollbar(child: scroll);
    } else {
      return scroll;
    }
  }
}
