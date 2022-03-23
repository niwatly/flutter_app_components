import 'package:flutter/material.dart';
import 'package:flutter_app_components/utility/extension.dart';
import 'package:gap/gap.dart';

/// 箇条書き
class ItemizedText extends StatelessWidget {
  const ItemizedText(
      this.texts, {
        Key? key,
        this.separator = const Gap(8),
      }) : super(key: key);

  final List<Text> texts;
  final Widget separator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: texts
          .map<Widget>(
            (x) => _ItemizedTextRow(x),
      )
          .insertBetween((_) => separator)
          .toList(),
    );
  }
}

class _ItemizedTextRow extends StatelessWidget {
  const _ItemizedTextRow(
      this.text, {
        Key? key,
      }) : super(key: key);

  final Text text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "・",
          style: text.style,
        ),
        Expanded(child: text),
      ],
    );
  }
}
