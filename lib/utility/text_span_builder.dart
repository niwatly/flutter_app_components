import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class TextSpanBuilder {
  static const urlRegExpPattern = r'https?://([\w-]+\.)+[\w-]+(/[\w-./?%&=~#+]*)?';
  static const phoneNumberRegExpPattern = r'[+0]\d+[\d-]+\d';
  static const emailRegExpPattern = r'[^@\s]+@([^@\s]+\.)+[^@\W]+';

  static const defaultLinkRegExpPatterns = [urlRegExpPattern];

  final List<String> linkRegExpPatterns;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final void Function(String url)? onUrlTapCallback;

  TextSpanBuilder({
    this.linkRegExpPatterns = defaultLinkRegExpPatterns,
    this.style,
    this.linkStyle,
    this.onUrlTapCallback,
  });

  TextSpan build(String text) {
    final elements = _generateElements(text);

    final textSpans = elements.map((x) {
      GestureRecognizer? recognizer = null;
      final callback = onUrlTapCallback;

      if (x.isLink && callback != null) {
        recognizer = TapGestureRecognizer() //
          ..onTap = () => callback(x.text);
      }

      return TextSpan(
        text: x.text,
        style: x.isLink ? linkStyle : style,
        recognizer: recognizer,
      );
    });

    return TextSpan(
      children: textSpans.toList(growable: false),
    );
  }

  Iterable<_Element> _generateElements(String text) sync* {
    if (text.isEmpty) {
      // テキストがそもそも空文字
      return;
    }

    final regexp = RegExp("(${(linkRegExpPatterns).join("|")})");
    final matches = regexp.allMatches(text);

    if (matches.isEmpty) {
      // 正規表現にマッチする箇所が0件
      yield _Element.text(text);

      return;
    }

    var index = 0;

    for (final match in matches) {
      if (match.start != 0) {
        // 前回のマッチ箇所終わりから今回の箇所始まりに囲まれている通常のテキストをElement化する
        yield _Element.text(text.substring(index, match.start));
      }

      final mateched = match.group(0);

      if (mateched != null) {
        // マッチしたテキストをElement化する
        yield _Element.link(mateched);
      }

      index = match.end;
    }

    if (index < text.length) {
      // 最後のマッチ箇所終わりからテキスト終端までをElement化する
      yield _Element.text(text.substring(index));
    }
  }
}

class _Element {
  final bool isLink;
  final String text;

  _Element({
    required this.isLink,
    required this.text,
  });

  _Element.text(String text) : this(isLink: false, text: text);

  _Element.link(String link) : this(isLink: true, text: link);
}
