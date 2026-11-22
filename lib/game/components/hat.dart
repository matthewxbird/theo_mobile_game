import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../teddy_game.dart';
import 'monster.dart';
import 'pickup.dart';

/// Draws a magic top hat with its brim centred on [brim].
void paintHat(Canvas canvas, Offset brim, {double scale = 1}) {
  canvas.save();
  canvas.translate(brim.dx, brim.dy);
  canvas.scale(scale);
  final crown = Paint()..color = const Color(0xFF3F2A6B);
  final band = Paint()..color = const Color(0xFFE53935);
  final star = Paint()..color = const Color(0xFFFFD54F);
  // Crown and brim.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(-15, -30, 30, 30),
      const Radius.circular(4),
    ),
    crown,
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: 46, height: 11),
    crown,
  );
  canvas.drawRect(const Rect.fromLTWH(-15, -11, 30, 6), band);
  // A little gold star on the front.
  canvas.drawPath(_starPath(const Offset(0, -20), 6), star);
  canvas.restore();
}

Path _starPath(Offset centre, double radius) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? radius : radius * 0.45;
    final a = -pi / 2 + i * pi / 5;
    final point = centre + Offset(cos(a) * r, sin(a) * r);
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

/// A special hat lying on the floor, twinkling so it's easy to spot.
class HatPickup extends Pickup {
  HatPickup({required super.position}) : super(size: 56);

  static final _sparkle = Paint()..color = const Color(0xFFFFF59D);
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < 4; i++) {
      final a = _time * 2 + i * pi / 2;
      final twinkle = 3 + 2 * sin(_time * 8 + i);
      final spot = const Offset(28, 28) + Offset(cos(a) * 30, sin(a) * 22);
      canvas.drawPath(_starPath(spot, twinkle), _sparkle);
    }
    paintHat(canvas, const Offset(28, 42));
  }
}

/// Teddy's hat spinning through the air towards a monster.
class ThrownHat extends PositionComponent with HasGameReference<TeddyGame> {
  ThrownHat({required super.position, required this.target})
    : super(size: Vector2.all(56), anchor: Anchor.center, priority: 4);

  static const _speed = 650.0;
  static const _hitDistance = 26.0;

  Monster target;

  @override
  void update(double dt) {
    super.update(dt);
    angle += dt * 14;

    // If the monster went away, find another one, or land on the floor.
    if (!target.isMounted || !target.isChasing) {
      final next = game.nearestMonsterTo(position);
      if (next == null) {
        game.add(HatPickup(position: game.clampToField(position)));
        removeFromParent();
        return;
      }
      target = next;
    }

    final toTarget = target.position - position;
    if (toTarget.length < _hitDistance) {
      target.coverEyesWithHat();
      removeFromParent();
      return;
    }
    position.add(toTarget.normalized()..scale(_speed * dt));
  }

  @override
  void render(Canvas canvas) => paintHat(canvas, const Offset(28, 38));
}
