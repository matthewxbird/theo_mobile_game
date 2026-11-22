import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// The grassy floor. Tapping anywhere on it tells Teddy where to go.
class Playground extends PositionComponent with TapCallbacks {
  Playground({required this.onTap}) : super(priority: -1);

  final void Function(Vector2 point) onTap;

  static final _petal = Paint()..color = const Color(0xFFFFFFFF);
  static final _middle = Paint()..color = const Color(0xFFFFD54F);

  // Flower positions as fractions of the screen, so they fit any size.
  final List<Offset> _flowers = List.generate(
    18,
    (i) => Offset(Random(i).nextDouble(), Random(i + 100).nextDouble()),
  );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onTapDown(TapDownEvent event) => onTap(event.localPosition);

  @override
  void render(Canvas canvas) {
    for (final f in _flowers) {
      final c = Offset(f.dx * size.x, f.dy * size.y);
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * pi / 5;
        canvas.drawCircle(c + Offset(cos(a) * 5, sin(a) * 5), 4, _petal);
      }
      canvas.drawCircle(c, 3.5, _middle);
    }
  }
}
