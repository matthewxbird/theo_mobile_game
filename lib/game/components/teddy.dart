import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../rules.dart';

/// The hero. Walks to wherever he is told to go.
class Teddy extends PositionComponent {
  Teddy({required super.position})
      : super(size: Vector2.all(76), anchor: Anchor.center, priority: 3);

  static final _fur = Paint()..color = const Color(0xFFA0642D);
  static final _light = Paint()..color = const Color(0xFFE8C39E);
  static final _dark = Paint()..color = const Color(0xFF3B2314);
  static final _smile = Paint()
    ..color = const Color(0xFF3B2314)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;

  Vector2? _target;
  double _safeTime = 0;
  double _time = 0;

  bool get isSafe => _safeTime > 0;
  bool get isMoving => _target != null;

  void moveTo(Vector2 target) => _target = target.clone();

  void makeSafe() => _safeTime = GameRules.safeSecondsAfterCatch;

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

    // Feet and arms.
    canvas.drawCircle(const Offset(28, 70), 7, _fur);
    canvas.drawCircle(const Offset(48, 70), 7, _fur);
    canvas.drawCircle(const Offset(17, 50), 7, _fur);
    canvas.drawCircle(const Offset(59, 50), 7, _fur);
    // Body and belly.
    canvas.drawCircle(const Offset(38, 54), 19, _fur);
    canvas.drawCircle(const Offset(38, 57), 11, _light);
    // Ears.
    canvas.drawCircle(const Offset(20, 12), 9, _fur);
    canvas.drawCircle(const Offset(56, 12), 9, _fur);
    canvas.drawCircle(const Offset(20, 12), 5, _light);
    canvas.drawCircle(const Offset(56, 12), 5, _light);
    // Head.
    canvas.drawCircle(const Offset(38, 28), 21, _fur);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(38, 36), width: 22, height: 15),
      _light,
    );
    // Face.
    canvas.drawCircle(const Offset(30, 24), 3, _dark);
    canvas.drawCircle(const Offset(46, 24), 3, _dark);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(38, 32), width: 9, height: 6),
      _dark,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(38, 36), width: 10, height: 7),
      0.2,
      pi - 0.4,
      false,
      _smile,
    );

    canvas.restore();
  }
}
