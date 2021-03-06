import 'package:flutter/material.dart';

class CheckBoxText extends StatelessWidget {
  final String label;
  final String? description;
  final Widget? leading;
  final Widget? secondary;
  final Function(bool newValue) onChanged;
  final bool checkBoxValue;
  final bool disable;
  final EdgeInsets? padding;
  final ListTileControlAffinity affinity;
  final bool expandBetweenCheckAndLabel;
  final TextStyle? descriptionTextStyle;

  const CheckBoxText({
    required this.label,
    required this.onChanged,
    required this.checkBoxValue,
    this.expandBetweenCheckAndLabel = true,
    this.padding,
    this.leading,
    this.secondary,
    this.description,
    this.disable = false,
    this.affinity = ListTileControlAffinity.trailing,
    this.descriptionTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final checkbox = Checkbox(
      value: checkBoxValue,
      onChanged: disable ? null : (v) => onChanged(v ?? false),
    );
    final _leading = leading;
    final _secondary = secondary;
    final _desc = description;
    // なんでおまえnullableなんだ...
    // ignore: avoid-non-null-assertion
    final bodyText2 = Theme.of(context).textTheme.bodyText2!;

    return InkWell(
      onTap: () => disable ? null : onChanged(!checkBoxValue),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// checkbox (if leading)
            if (affinity == ListTileControlAffinity.leading) //
              checkbox
            else
              const SizedBox(width: 16),

            /// leading
            if (_leading != null) _leading,

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
                    style: bodyText2.apply(
                      color: disable ? Theme.of(context).disabledColor : bodyText2.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (_desc != null)
                    Text(
                      _desc,
                      maxLines: 5,
                      textAlign: TextAlign.left,
                      style: descriptionTextStyle ?? Theme.of(context).textTheme.caption,
                    ),
                ],
              ),
            ),

            /// secondary
            if (_secondary != null) _secondary,

            /// checkbox (if trailing)
            if (affinity == ListTileControlAffinity.trailing) //
              checkbox
            else
              const SizedBox(width: 16),
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
    required this.expand,
    required this.child,
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
