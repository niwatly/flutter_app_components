import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotNullSelector<T, V> extends Selector<T, V?> {
  NotNullSelector({
    Key? key,
    required V? Function(BuildContext, T) selector,
    required Widget Function(BuildContext, V) builder,
    Widget Function(BuildContext)? ifNullBuilder,
    ShouldRebuild<V?>? shouldRebuild,
  }) : super(
          key: key,
          shouldRebuild: shouldRebuild,
          selector: (context, x) => selector(context, x),
          builder: (context, x, child) {
            if (x == null) {
              return ifNullBuilder?.call(context) ?? const SizedBox.shrink();
            }

            return builder(context, x);
          },
        );
}
