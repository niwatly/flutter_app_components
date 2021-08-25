import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoolSelector<T> extends Selector<T, bool> {
  BoolSelector({
    Key? key,
    required bool Function(BuildContext, T) selector,
    required Widget Function(BuildContext) builder,
    ShouldRebuild<bool>? shouldRebuild,
  }) : super(
          key: key,
          shouldRebuild: shouldRebuild,
          builder: (context, x, child) => x ? builder(context) : SizedBox.shrink(),
          selector: (context, x) => selector(context, x),
        );
}

class BoolSelector2<T, S> extends Selector2<T, S, bool> {
  BoolSelector2({
    Key? key,
    required bool Function(BuildContext, T, S) selector,
    required Widget Function(BuildContext) builder,
    ShouldRebuild<bool>? shouldRebuild,
  }) : super(
          key: key,
          shouldRebuild: shouldRebuild,
          builder: (context, x, child) => x ? builder(context) : SizedBox.shrink(),
          selector: (context, t, s) => selector(context, t, s),
        );
}
