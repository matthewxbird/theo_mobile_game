import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../rules.dart';
import '../teddy_colour.dart';

/// The hero. Walks to wherever he is told to go.
class Teddy extends PositionComponent {
  Teddy({required super.position})
    : super(size: Vector2.all(76), anchor: Anchor.center, priority: 3);

  TeddyColour colour = TeddyColour.brown;

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

    final bob = isMoving ? sin(_time * 14) * 3 : 0.0;
    canvas.save();
    canvas.translate(0, bob);
    paintTeddy(canvas, colour.fur);
    canvas.restore();
  }
}
