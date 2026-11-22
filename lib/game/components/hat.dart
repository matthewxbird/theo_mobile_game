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
  canvas.drawPath(starPath(const Offset(0, -20), 6), star);
  canvas.restore();
}

/// A five-pointed star shape.
Path starPath(Offset centre, double radius) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? radius : radius * 0.45;
    final a = -pi / 2 + i * pi / 5;
    final point = centre + Offset(cos(a) * r, sin(a) * r);
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

/// The special things you can find and throw (kid's pick: hats, and
/// sometimes ribbons).
enum Gift {
  /// Lands over a bad guy's eyes; it runs off the screen.
  hat,

  /// Ties a bad guy up in a bow; it falls over and flashes away.
  ribbon,
}

/// Draws a pink ribbon bow centred on [centre].
void paintRibbon(Canvas canvas, Offset centre, {double scale = 1}) {
  canvas.save();
  canvas.translate(centre.dx, centre.dy);
  canvas.scale(scale);
  final pink = Paint()..color = const Color(0xFFEC407A);
  final light = Paint()..color = const Color(0xFFF8BBD0);
  // Two tails hanging down.
  for (final side in const [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 2)
        ..lineTo(side * 10, 16)
        ..lineTo(side * 4, 15)
        ..close(),
      pink,
    );
  }
  // Two loops and the knot.
  for (final side in const [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(side * 18, -14, side * 18, 0)
        ..quadraticBezierTo(side * 18, 12, 0, 0)
        ..close(),
      pink,
    );
    canvas.drawCircle(Offset(side * 10, -2), 3, light);
  }
  canvas.drawCircle(Offset.zero, 5, pink);
  canvas.drawCircle(const Offset(-1.5, -1.5), 1.8, light);
  canvas.restore();
}

/// Draws [gift] for the floor or the air: a hat on its brim, or a bow.
void paintGift(Canvas canvas, Gift gift, Offset brim, {double scale = 1}) {
  switch (gift) {
    case Gift.hat:
      paintHat(canvas, brim, scale: scale);
    case Gift.ribbon:
      paintRibbon(canvas, brim - Offset(0, 12 * scale), scale: scale * 1.3);
  }
}

/// A special hat or ribbon lying on the floor, twinkling so it's easy to
/// spot.
class HatPickup extends Pickup {
  HatPickup({required super.position, this.gift = Gift.hat}) : super(size: 56);

  final Gift gift;

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
      canvas.drawPath(starPath(spot, twinkle), _sparkle);
    }
    paintGift(canvas, gift, const Offset(28, 42));
  }
}

/// Teddy's hat (or ribbon) spinning through the air towards a monster.
class ThrownHat extends PositionComponent with HasGameReference<TeddyGame> {
  ThrownHat({
    required super.position,
    required this.target,
    this.gift = Gift.hat,
  }) : super(size: Vector2.all(56), anchor: Anchor.center, priority: 4);

  static const _speed = 650.0;
  static const _hitDistance = 26.0;

  Monster target;
  final Gift gift;

  @override
  void update(double dt) {
    super.update(dt);
    angle += dt * 14;

    // If the monster went away, find another one, or land on the floor.
    if (!target.isMounted || !target.isChasing) {
      final next = game.nearestMonsterTo(position);
      if (next == null) {
        // Never two hats on the floor: if one's there, this one goes back
        // on Teddy's head instead.
        if (game.hasHatOnFloor) {
          game.teddy.putOn(gift);
        } else {
          game.add(
            HatPickup(position: game.clampToField(position), gift: gift),
          );
        }
        removeFromParent();
        return;
      }
      target = next;
    }

    final toTarget = target.position - position;
    if (toTarget.length < _hitDistance) {
      switch (gift) {
        case Gift.hat:
          target.coverEyesWithHat();
        case Gift.ribbon:
          target.tieUpWithRibbon();
      }
      removeFromParent();
      return;
    }
    position.add(toTarget.normalized()..scale(_speed * dt));
  }

  @override
  void render(Canvas canvas) => paintGift(canvas, gift, const Offset(28, 38));
}
