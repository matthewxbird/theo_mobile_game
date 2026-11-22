import 'dart:ui';

import 'package:flame/components.dart';

import 'monster.dart';
import 'sweet.dart';

/// A lollipop snatched from Teddy, flying into a monster's mouth.
/// Once eaten it's gone for good.
class StolenLolly extends PositionComponent {
  StolenLolly({
    required super.position,
    required this.monster,
    required Color color,
  }) : _candy = Paint()..color = color,
       super(size: Vector2.all(40), anchor: Anchor.center, priority: 4);

  static const _flightTime = 0.4;

  final Monster monster;
  final Paint _candy;
  late final Vector2 _from = position.clone();
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!monster.isMounted) {
      removeFromParent();
      return;
    }
    _time += dt;
    final t = (_time / _flightTime).clamp(0.0, 1.0);
    // Fly in an arc towards the monster's mouth, shrinking as it goes.
    final mouth = monster.position + Vector2(0, 10);
    position
      ..setFrom(_from + (mouth - _from) * t)
      ..y -= 60 * t * (1 - t) * 4;
    scale.setAll(1 - 0.6 * t);
    angle = t * 8;
    if (t >= 1) {
      monster.eat();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) => Sweet.paintLolly(canvas, _candy);
}
