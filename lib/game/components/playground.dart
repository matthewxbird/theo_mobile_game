import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../place.dart';
import 'hat.dart';

/// The floor Teddy plays on: a meadow, a beach, snow or night, depending on
/// the level. Tapping anywhere on it tells Teddy where to go.
class Playground extends PositionComponent with TapCallbacks {
  Playground({required this.onTap, required this.place}) : super(priority: -1);

  final void Function(Vector2 point) onTap;

  /// Which place to draw right now.
  final Place Function() place;

  static final _white = Paint()..color = const Color(0xFFFFFFFF);
  static final _yellow = Paint()..color = const Color(0xFFFFD54F);
  static final _ground = Paint();
  static final _sea = Paint()..color = const Color(0xFF4FC3F7);
  static final _foam = Paint()..color = const Color(0xCCFFFFFF);
  static final _shell = Paint()..color = const Color(0xFFF8BBD0);
  static final _shellLine =
      Paint()
        ..color = const Color(0xFFE91E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
  static final _starfish = Paint()..color = const Color(0xFFFF8A65);
  static final _drift = Paint()..color = const Color(0xFFFFFFFF);
  static final _snowflake = Paint()..color = const Color(0xDDFFFFFF);
  static final _moon = Paint()..color = const Color(0xFFFFF9C4);
  static final _crater = Paint()..color = const Color(0x33FFD54F);

  double _time = 0;

  // Decoration spots as fractions of the screen, so they fit any size.
  final List<Offset> _spots = List.generate(
    18,
    (i) => Offset(Random(i).nextDouble(), Random(i + 100).nextDouble()),
  );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void onTapDown(TapDownEvent event) => onTap(event.localPosition);

  @override
  void render(Canvas canvas) {
    final where = place();
    _ground.color = where.ground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _ground);
    switch (where) {
      case Place.meadow:
        _drawMeadow(canvas);
      case Place.beach:
        _drawBeach(canvas);
      case Place.snow:
        _drawSnow(canvas);
      case Place.night:
        _drawNight(canvas);
    }
  }

  Iterable<Offset> get _points =>
      _spots.map((f) => Offset(f.dx * size.x, f.dy * size.y));

  void _drawMeadow(Canvas canvas) {
    for (final c in _points) {
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * pi / 5;
        canvas.drawCircle(c + Offset(cos(a) * 5, sin(a) * 5), 4, _white);
      }
      canvas.drawCircle(c, 3.5, _yellow);
    }
  }

  void _drawBeach(Canvas canvas) {
    // The sea along the top, with waves rolling in and out.
    final tide = 70 + sin(_time * 1.2) * 8;
    final sea = Path()..moveTo(0, 0);
    for (var x = 0.0; x <= size.x; x += 20) {
      sea.lineTo(x, tide + sin(x / 30 + _time * 2) * 6);
    }
    sea
      ..lineTo(size.x, 0)
      ..close();
    canvas.drawPath(sea, _sea);
    for (var x = 10.0; x < size.x; x += 40) {
      canvas.drawCircle(
        Offset(x, tide + sin(x / 30 + _time * 2) * 6),
        5,
        _foam,
      );
    }
    // Shells and starfish on the sand.
    var i = 0;
    for (final c in _points) {
      if (c.dy < tide + 30) continue;
      i++;
      if (i.isEven) {
        canvas.drawArc(
          Rect.fromCenter(center: c, width: 14, height: 12),
          pi,
          pi,
          true,
          _shell,
        );
        for (final dx in const [-3.0, 0.0, 3.0]) {
          canvas.drawLine(c, c + Offset(dx * 1.5, -5), _shellLine);
        }
      } else {
        canvas.drawPath(starPath(c, 8), _starfish);
      }
    }
  }

  void _drawSnow(Canvas canvas) {
    // Soft snow drifts.
    for (final c in _points) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 34, height: 12),
        _drift,
      );
    }
    // Snowflakes drifting down and swaying.
    for (var i = 0; i < 40; i++) {
      final r = Random(i + 500);
      final speed = 20 + r.nextDouble() * 30;
      final y = (r.nextDouble() * size.y + _time * speed) % size.y;
      final x = r.nextDouble() * size.x + sin(_time + r.nextDouble() * 6) * 12;
      canvas.drawCircle(Offset(x, y), 2 + r.nextDouble() * 2.5, _snowflake);
    }
  }

  void _drawNight(Canvas canvas) {
    // A big friendly moon.
    final moon = Offset(size.x - 70, 170);
    canvas.drawCircle(moon, 34, _moon);
    canvas.drawCircle(moon + const Offset(-10, -6), 7, _crater);
    canvas.drawCircle(moon + const Offset(9, 10), 5, _crater);
    // Twinkling stars.
    var i = 0;
    for (final c in _points) {
      i++;
      final twinkle = 3 + 2 * sin(_time * 3 + i);
      canvas.drawPath(starPath(c, twinkle), _yellow);
    }
  }
}
