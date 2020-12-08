import 'package:flutter/material.dart';
import 'package:flutter_app_components/view/lazy_future_builder.dart';
import 'package:flutter_app_components/view/trace_stack.dart';

class InkWellImage extends StatelessWidget {
  final WidgetBuilder imageBuilder;
  final Future Function() onTap;

  const InkWellImage({
    this.imageBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TraceStack(
      children: [
        TraceStackChild.base(
          child: imageBuilder(context),
        ),
        TraceStackChild.follow(
          child: LazyFutureBuilder(
            futureBuilder: onTap,
            builder: (context, futureBuilder, isFutureBuilding) => Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: futureBuilder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
