import 'dart:math';

import 'package:flutter/material.dart';

import 'lazy_future_builder.dart';

class RefreshButton extends StatefulWidget {
  final Future Function() onRefresh;
  final IconData icon;

  const RefreshButton({
    this.onRefresh,
    this.icon = Icons.refresh,
  });

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RefreshButton> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0,
      upperBound: pi * 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LazyFutureBuilder(
      futureBuilder: () async {
        _controller.repeat();
        try {
          await widget.onRefresh();
        } finally {
          _controller.stop();
        }
      },
      builder: (context, futureBuilder, isFutureBuilding) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          child: child,
          angle: _controller.value,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.refresh,
          ),
          onPressed: futureBuilder,
        ),
      ),
    );
  }
}
