import 'package:flutter/widgets.dart';

class _Behavior extends ScrollBehavior {
  const _Behavior();
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;
}

class NoGlowScrollConfiguration extends StatelessWidget {
  final Widget child;

  const NoGlowScrollConfiguration({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _Behavior(),
      child: child,
    );
  }
}
