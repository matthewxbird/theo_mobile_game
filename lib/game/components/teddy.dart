import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../rules.dart';
import '../teddy_colour.dart';
import 'hat.dart';

/// The hero. Walks to wherever he is told to go.
class Teddy extends PositionComponent {
  Teddy({required super.position})
    : super(size: Vector2.all(76), anchor: Anchor.center, priority: 3);

  TeddyColour colour = TeddyColour.brown;

  /// Wearing the special hat? Tap Teddy to throw it at a monster.
  bool hasHat = false;

  static final _tapMeRing =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

  Vector2? _target;
  double _safeTime = 0;
  double _time = 0;

  bool get isSafe => _safeTime > 0;
  bool get isMoving => _target != null;

  void moveTo(Vector2 target) => _target = target.clone();

  void makeSafe() => _safeTime = GameRules.safeSecondsAfterCatch;

  /// Stand still at [point], ready for a new level.
  void resetTo(Vector2 point) {
    position.setFrom(point);
    _target = null;
    _safeTime = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_safeTime > 0) _safeTime = max(0, _safeTime - dt);

    final target = _target;
    if (target == null) return;
    final toTarget = target - position;
    final step = GameRules.teddySpeed * dt;
    if (toTarget.length <= step) {
      position.setFrom(target);
      _target = null;
    } else {
      position.add(toTarget.normalized()..scale(step));
    }
  }

  @override
  void render(Canvas canvas) {
    // Blink while safe after being caught.
    if (isSafe && (_time * 10).floor().isEven) return;

    if (hasHat) {
      // A gentle pulsing ring says "tap me!".
      final pulse = (sin(_time * 5) + 1) / 2;
      _tapMeRing.color = Color.fromRGBO(255, 235, 59, 0.4 + 0.5 * pulse);
      canvas.drawCircle(const Offset(38, 42), 46 + 6 * pulse, _tapMeRing);
    }

    final bob = isMoving ? sin(_time * 14) * 3 : 0.0;
    canvas.save();
    canvas.translate(0, bob);
    paintTeddy(canvas, colour.fur);
    if (hasHat) paintHat(canvas, const Offset(38, 10), scale: 0.9);
    canvas.restore();
  }
}
