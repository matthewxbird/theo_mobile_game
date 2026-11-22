import 'dart:ui';

import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;

final _painters = <String, TextPainter>{};

/// Draws an emoji centred on [centre], about [size] pixels tall.
void paintEmoji(Canvas canvas, String emoji, Offset centre, double size) {
  final painter = _painters.putIfAbsent(
    '$emoji@$size',
    () => TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout(),
  );
  painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
}
