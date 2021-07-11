import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
// ignore: implementation_imports
import 'package:tutorial_coach_mark/src/widgets/tutorial_coach_mark_widget.dart';

class TutorialCoachMarkOverlay {
  final OverlayState overlay;
  final List<TargetFocus> targets;
  final Function(TargetFocus)? onClickTarget; //optional
  final Function(TargetFocus)? onClickOverlay; //optional
  final Function()? onFinish; //optional
  final double paddingFocus;
  final Function()? onSkip; //optional
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final Color colorShadow;
  final double opacityShadow;
  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();
  final Duration focusAnimationDuration;
  final Duration pulseAnimationDuration;
  final Widget? skipWidget; //optional

  OverlayEntry? _overlayEntry;

  TutorialCoachMarkOverlay(this.overlay,
      {required this.targets, //required
      this.colorShadow = Colors.black,
      this.onClickTarget,
      this.onClickOverlay,
      this.onFinish,
      this.paddingFocus = 10,
      this.onSkip,
      this.alignSkip = Alignment.bottomRight,
      this.textSkip = "SKIP",
      this.textStyleSkip = const TextStyle(color: Colors.white),
      this.hideSkip = false,
      this.opacityShadow = 0.8,
      this.focusAnimationDuration = const Duration(milliseconds: 600),
      this.pulseAnimationDuration = const Duration(milliseconds: 500),
      this.skipWidget})
      : assert(opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay() {
    return OverlayEntry(builder: (context) {
      return TutorialCoachMarkWidget(
        key: _widgetKey,
        targets: targets,
        clickTarget: onClickTarget,
        paddingFocus: paddingFocus,
        onClickSkip: skip,
        alignSkip: alignSkip,
        textSkip: textSkip,
        textStyleSkip: textStyleSkip,
        hideSkip: hideSkip,
        colorShadow: colorShadow,
        opacityShadow: opacityShadow,
        finish: finish,
      );
    });
  }

  void show() {
    if (_overlayEntry == null) {
      overlay.insert(_overlayEntry = _buildOverlay());
    }
  }

  void finish() {
    onFinish?.call();
    _removeOverlay();
  }

  void skip() {
    onSkip?.call();
    _removeOverlay();
  }

  void next() => _widgetKey.currentState?.next();
  void previous() => _widgetKey.currentState?.previous();

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
