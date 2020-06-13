import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LazyFutureBuilder extends StatelessWidget {
  final Future Function() futureBuilder;
  final Widget Function(BuildContext context, Future Function() futureBuilder, bool isFutureBuilding) builder;
  
  const LazyFutureBuilder({
    @required this.futureBuilder,
    @required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_Notifier>(
      create: (context) => _Notifier(),
      child: Consumer<_Notifier>(
        builder: (context, notifier, child) => builder(
          context,
              () async {
            if (notifier.value) {
              return;
            }
            
            try {
              notifier.value = true;
              await futureBuilder();
            } finally {
              if (!notifier.disposed) {
                notifier.value = false;
              }
            }
          },
          notifier.value,
        ),
      ),
    );
  }
}

class _Notifier extends ValueNotifier<bool> {
  bool disposed = false;
  _Notifier() : super(false);
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
