import 'package:flutter/material.dart';

class FloatingDialog extends StatelessWidget {
  final Widget child;
  final double widthFactor;
  final String title;
  final BorderRadius cornerRadius;
  final EdgeInsets contentPadding;
  final Color backgroundColor;
  final void Function() onClose;

  const FloatingDialog({
    @required this.child,
    this.onClose,
    this.title,
    this.cornerRadius = const BorderRadius.all(Radius.circular(8)),
    this.contentPadding = const EdgeInsets.all(24),
    this.widthFactor = 0.8,
    this.backgroundColor = const Color(0x80000000),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      /// 枠外タップでダイアログを消したい
      body: GestureDetector(
        onTap: onClose ?? () => Navigator.of(context).pop(),
        child: LayoutBuilder(
          /// コンテンツの高さが画面幅を超えるときはスクロールさせたい
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),

            /// コンテンツの横幅を0.8倍にして中央に表示したい
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth * widthFactor, minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 48, 0, 48),

                  /// コンテンツの縦幅は可変にしつつ、親のサイズを画面いっぱいまで伸ばすことで
                  /// コンテンツの高さによらず中央揃えしたい
                  child: Center(
                    /// コンテンツがクリックされてもダイアログを消したくない（Scaffold直下のGestureDetectorまで伝搬してしまう）
                    child: GestureDetector(
                      onTap: () {},
                      child: Material(
                        borderRadius: cornerRadius,
                        color: DialogTheme.of(context).backgroundColor,
                        child: ClipRRect(
                          borderRadius: cornerRadius,
                          child: Padding(
                            padding: contentPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (title != null) ...[
                                  Text(
                                    title,
                                    textAlign: TextAlign.left,
                                    style: DialogTheme.of(context).titleTextStyle,
                                  ),
                                ],
                                child,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
