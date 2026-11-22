import 'dart:math';
import 'dart:ui';

import 'pickup.dart';

/// A lollipop. Each one is a point.
class Sweet extends Pickup {
  Sweet({required super.position, required Color color})
    : _candy = Paint()..color = color,
      super(size: 40);

  static const colors = [
    Color(0xFFE53935),
    Color(0xFFEC407A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFFF9800),
  ];

  static final _stick =
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
  static final _swirl =
      Paint()
        ..color = const Color(0xCCFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

  final Paint _candy;

  @override
  void render(Canvas canvas) => paintLolly(canvas, _candy);

  /// Draws a lollipop in a 40 x 40 box.
  static void paintLolly(Canvas canvas, Paint candy) {
    canvas.drawLine(const Offset(20, 24), const Offset(20, 40), _stick);
    canvas.drawCircle(const Offset(20, 15), 14, candy);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(20, 15), radius: 8),
      0,
      pi * 1.5,
      false,
      _swirl,
    );
  }
}
