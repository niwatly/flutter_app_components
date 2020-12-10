import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_components/view/lazy_future_builder.dart';
import 'package:flutter_app_components/view/trace_stack.dart';

class InkWellImage extends StatelessWidget {
  final WidgetBuilder imageBuilder;
  final FutureOr Function() onTap;
  final Alignment alignment;

  const InkWellImage({
    this.imageBuilder,
    this.onTap,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return TraceStack(
      alignment: alignment,
      children: [
        TraceStackChild.base(
          child: imageBuilder(context),
        ),
        if (onTap != null)
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
