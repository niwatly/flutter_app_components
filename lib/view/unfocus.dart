import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class Unfocus extends StatelessWidget {
  final bool unfocusWhenTapped;
  final bool unfocusWhenScrollStarted;
  final Widget child;

  const Unfocus({
    this.unfocusWhenTapped = false,
    this.unfocusWhenScrollStarted = false,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var ret = child;

    if (unfocusWhenTapped) {
      ret = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ret,
      );
    }

    if (unfocusWhenScrollStarted) {
      ret = ChangeNotifierProvider<_ScrollDirectionNotifier>(
        create: (context) => _ScrollDirectionNotifier(
          () => FocusScope.of(context).unfocus(),
        ),
        builder: (context, child) => NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            context.read<_ScrollDirectionNotifier>().value = notification.direction;
            return false;
          },
          child: child,
        ),
        child: ret,
      );
    }

    return ret;
  }
}

class _ScrollDirectionNotifier extends ValueNotifier<ScrollDirection> {
  final VoidCallback onScrollStarted;

  _ScrollDirectionNotifier(this.onScrollStarted) : super(ScrollDirection.idle);

  @override
  set value(ScrollDirection newValue) {
    if (super.value != newValue) {
      super.value = newValue;
      if (newValue != ScrollDirection.idle) {
        onScrollStarted();
      }
    }
  }
}
