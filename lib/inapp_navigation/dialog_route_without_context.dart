import 'package:flutter/material.dart';

class DialogRouteWithoutContext<T> extends RawDialogRoute<T> {
  /// A dialog route with Material entrance and exit animations,
  /// modal barrier color, and modal barrier behavior (dialog is dismissible
  /// with a tap on the barrier).
  DialogRouteWithoutContext({
    required WidgetBuilder builder,
    CapturedThemes? themes,
    Color? barrierColor = Colors.black54,
    bool barrierDismissible = true,
    String? barrierLabel,
    bool useSafeArea = true,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
            final Widget pageChild = Builder(builder: builder);
            Widget dialog = themes?.wrap(pageChild) ?? pageChild;
            if (useSafeArea) {
              dialog = SafeArea(child: dialog);
            }

            return dialog;
          },
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          transitionDuration: const Duration(milliseconds: 150),
          transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
          settings: settings,
        );
}

double _paddingScaleFactor(double textScaleFactor) {
  final double clampedTextScaleFactor = textScaleFactor.clamp(1.0, 2.0).toDouble();
  // The final padding scale factor is clamped between 1/3 and 1. For example,
  // a non-scaled padding of 24 will produce a padding between 24 and 8.
  return lerpDouble(1.0, 1.0 / 3.0, clampedTextScaleFactor - 1.0)!;
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN == true) && (b?.isNaN == true)) return a?.toDouble();
  a ??= 0.0;
  b ??= 0.0;
  assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(t.isFinite, 't must be finite when interpolating between values');
  return a * (1.0 - t) + b * t;
}
