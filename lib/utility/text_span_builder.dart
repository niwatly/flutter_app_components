import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class TextSpanBuilder {
  static const urlRegExpPattern = r'https?://([\w-]+\.)+[\w-]+(/[\w-./?%&=~#+]*)?';
  static const phoneNumberRegExpPattern = r'[+0]\d+[\d-]+\d';
  static const emailRegExpPattern = r'[^@\s]+@([^@\s]+\.)+[^@\W]+';

  static const defaultLinkRegExpPatterns = [urlRegExpPattern, phoneNumberRegExpPattern, emailRegExpPattern];

  final List<String> linkRegExpPatterns;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final void Function(String? url)? onUrlTapCallback;

  TextSpanBuilder({
    this.linkRegExpPatterns = defaultLinkRegExpPatterns,
    this.style,
    this.linkStyle,
    this.onUrlTapCallback,
  });

  TextSpan build(String text) {
    final elements = _generateElements(text);

    final textSpans = elements.map((x) {
      final recognizer = x.isLink! && onUrlTapCallback != null
          ? (TapGestureRecognizer() //
            ..onTap = () => onUrlTapCallback!(x.text))
          : null;

      return TextSpan(
        text: x.text,
        style: x.isLink! ? linkStyle : style,
        recognizer: recognizer,
      );
    });

    return TextSpan(
      children: textSpans.toList(growable: false),
    );
  }

  Iterable<_Element> _generateElements(String text) sync* {
    if (text.isEmpty) {
      return;
    }

    final regexp = RegExp("(${(linkRegExpPatterns).join("|")})");
    final matches = regexp.allMatches(text);

    if (matches.isEmpty) {
      yield _Element.text(text);
      return;
    }

    var index = 0;

    for (final match in matches) {
      if (match.start != 0) {
        yield _Element.text(text.substring(index, match.start));
      }
      yield _Element.link(match.group(0));

      index = match.end;
    }
    if (index < text.length) {
      yield _Element.text(text.substring(index));
    }
  }
}

class _Element {
  final bool? isLink;
  final String? text;

  _Element({this.isLink, this.text});

  _Element.text(String text) : this(isLink: false, text: text);

  _Element.link(String? link) : this(isLink: true, text: link);
}
