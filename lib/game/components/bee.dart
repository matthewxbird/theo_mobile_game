import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../sfx.dart';
import '../teddy_colour.dart';
import 'emoji.dart';
import 'monster.dart';

/// A bee from the beehive. Zooms (wobbling) to a monster and stings it.
class Bee extends PositionComponent {
  Bee({
    required super.position,
    required this.target,
    required double delay,
    this.critter = Critter.bear,
  }) : _delay = delay,
       super(size: Vector2(30, 24), anchor: Anchor.center, priority: 4);

  static const _speed = 420.0;
  static const _stingDistance = 20.0;

  static final _body = Paint()..color = const Color(0xFFFFD54F);
  static final _stripe =
      Paint()
        ..color = const Color(0xFF212121)
        ..strokeWidth = 3.5;
  static final _wing = Paint()..color = const Color(0xCCFFFFFF);
  static final _eye = Paint()..color = const Color(0xFF212121);

  final Monster target;

  /// Whose helper this is: bees for bears, baby dinos, chicks or puppies.
  final Critter critter;
  double _delay;
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_delay > 0) {
      _delay -= dt;
      return;
    }
    _time += dt;

    if (!target.isMounted) {
      removeFromParent();
      return;
    }

    final toTarget = target.position - position;
    if (toTarget.length < _stingDistance) {
      if (target.isChasing) {
        target.flashAndFade();
        Sfx.sting.play();
      }
      removeFromParent();
      return;
    }

    final direction = toTarget.normalized();
    final sideways = Vector2(-direction.y, direction.x);
    position
      ..add(direction * (_speed * dt))
      ..add(sideways * (cos(_time * 18) * 140 * dt));
    // Face the way we're flying.
    scale.x = direction.x < 0 ? -1 : 1;
  }

  @override
  void render(Canvas canvas) {
    if (_delay > 0) return;
    if (critter != Critter.bear) {
      // Baby dinos, chicks or puppies, bouncing along.
      final hop = -sin(_time * 25).abs() * 4;
      paintEmoji(canvas, critter.swarm, Offset(15, 12 + hop), 28);
      return;
    }
    final flap = sin(_time * 60) * 3;
    canvas.drawOval(Rect.fromLTWH(8, 0 + flap, 9, 11), _wing);
    canvas.drawOval(Rect.fromLTWH(14, 1 - flap, 9, 11), _wing);
    canvas.drawOval(const Rect.fromLTWH(3, 7, 24, 16), _body);
    canvas.drawLine(const Offset(12, 8), const Offset(12, 22), _stripe);
    canvas.drawLine(const Offset(18, 8), const Offset(18, 22), _stripe);
    canvas.drawCircle(const Offset(24, 13), 2, _eye);
  }
}
