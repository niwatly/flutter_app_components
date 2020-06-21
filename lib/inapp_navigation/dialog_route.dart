import 'package:flutter/material.dart';

class DialogRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  DialogRoute({
    RouteSettings settings,
    this.builder,
    this.barrierDismissible = true,
  }) : super(settings: settings);

  @override
  final bool barrierDismissible;

  @override
  String get barrierLabel => null;

  @override
  Color get barrierColor => const Color(0x80000000);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.linear,
        ),
        child: child);
  }
}
