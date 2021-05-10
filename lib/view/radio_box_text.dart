import 'package:flutter/material.dart';

class RadioBoxText<T> extends StatelessWidget {
  final String label;
  final String description;
  final Widget leading;
  final Widget secondary;
  final Function(T newValue) onChanged;
  final T radioCurrentValue;
  final T radioMyValue;
  final bool disable;
  final EdgeInsets padding;
  final ListTileControlAffinity affinity;
  final bool expandBetweenCheckAndLabel;
  final TextStyle descriptionTextStyle;
  final TextStyle labelTextStyle;

  const RadioBoxText({
    @required this.label,
    @required this.onChanged,
    @required this.radioCurrentValue,
    @required this.radioMyValue,
    this.leading,
    this.secondary,
    this.description,
    this.disable = false,
    this.padding,
    this.affinity = ListTileControlAffinity.trailing,
    this.expandBetweenCheckAndLabel = true,
    this.descriptionTextStyle,
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final radio = Radio<T>(
      value: radioMyValue,
      groupValue: radioCurrentValue,
      onChanged: disable ? null : (v) => onChanged(v),
    );
    final _labelTextStyle = (labelTextStyle ?? Theme.of(context).textTheme.bodyText2);
    return InkWell(
      onTap: () => disable ? null : onChanged(radioMyValue),
      splashColor: Colors.transparent,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// radio (if leading)
            if (affinity == ListTileControlAffinity.leading) radio else const SizedBox(width: 16),

            /// leading
            if (leading != null) leading,

            /// label
            _FlexibleOrExpand(
              expand: expandBetweenCheckAndLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    style: _labelTextStyle.apply(
                      color: disable ? Theme.of(context).disabledColor : _labelTextStyle.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (description != null)
                    Text(
                      description,
                      maxLines: 5,
                      textAlign: TextAlign.left,
                      style: descriptionTextStyle ?? Theme.of(context).textTheme.caption,
                    ),
                ],
              ),
            ),

            /// secondary
            if (secondary != null) secondary,

            /// radio (if trailing)
            if (affinity == ListTileControlAffinity.trailing) radio else const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _FlexibleOrExpand extends StatelessWidget {
  final bool expand;
  final Widget child;

  const _FlexibleOrExpand({
    this.expand,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (expand) {
      return Expanded(
        child: child,
      );
    } else {
      return Flexible(
        child: child,
      );
    }
  }
}
