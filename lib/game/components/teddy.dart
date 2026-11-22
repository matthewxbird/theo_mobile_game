import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/animation.dart';

import '../rules.dart';
import '../teddy_colour.dart';
import 'hat.dart';

/// The hero. Walks to wherever he is told to go, and is full of life:
/// he breathes, blinks, looks where he's going, waddles, hops for joy,
/// and wears his special hat with style.
class Teddy extends PositionComponent {
  Teddy({required super.position})
    : super(size: Vector2.all(76), anchor: Anchor.center, priority: 3);

  static const _hopTime = 0.4;
  static const _hatDropTime = 0.5;
  static const _throwTime = 0.35;

  static final _tapMeRing =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

  final _random = Random();

  TeddyColour colour = TeddyColour.brown;

  Vector2? _target;
  double _safeTime = 0;
  double _time = 0;

  // Little animations, each counting down to 0.
  double _hop = 0;
  double _hatDrop = 0;
  double _throw = 0;
  double _blinkIn = 2;
  double _blink = 0;
  Offset _look = Offset.zero;

  bool _hasHat = false;

  /// Wearing the special hat? Tap Teddy to throw it at a monster.
  bool get hasHat => _hasHat;
  set hasHat(bool value) {
    // Putting a hat on: it drops onto his head with a bounce.
    if (value && !_hasHat) _hatDrop = _hatDropTime;
    _hasHat = value;
  }

  bool get isSafe => _safeTime > 0;
  bool get isMoving => _target != null;

  void moveTo(Vector2 target) => _target = target.clone();

  void makeSafe() => _safeTime = GameRules.safeSecondsAfterCatch;

  /// A little hop for joy (picking something up).
  void celebrate() => _hop = _hopTime;

  /// Swing his arms up and fling the hat.
  void throwHat() {
    _hasHat = false;
    _throw = _throwTime;
  }

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
    _hop = max(0, _hop - dt);
    _hatDrop = max(0, _hatDrop - dt);
    _throw = max(0, _throw - dt);
    _updateBlink(dt);

    final target = _target;
    var wantLook = Offset.zero;
    if (target != null) {
      final toTarget = target - position;
      final step = GameRules.teddySpeed * dt;
      if (toTarget.length <= step) {
        position.setFrom(target);
        _target = null;
      } else {
        final direction = toTarget.normalized();
        position.add(direction * step);
        wantLook = Offset(direction.x, direction.y);
      }
    }
    // Eyes drift smoothly towards where he's heading.
    _look = Offset.lerp(_look, wantLook, min(1, dt * 8))!;
  }

  void _updateBlink(double dt) {
    if (_blink > 0) {
      _blink -= dt;
      return;
    }
    _blinkIn -= dt;
    if (_blinkIn <= 0) {
      _blink = 0.14;
      _blinkIn = 2 + _random.nextDouble() * 3;
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

    // Waddle side to side and bounce while walking; breathe when still.
    final walkCycle = sin(_time * 14);
    final tilt = isMoving ? walkCycle * 0.12 : sin(_time * 1.6) * 0.03;
    final bounce = isMoving ? -walkCycle.abs() * 4 : 0.0;
    final breathe = isMoving ? 0.0 : sin(_time * 2.5) * 0.025;

    // Hop for joy: squash, jump, squash.
    var jump = 0.0;
    var squash = 0.0;
    if (_hop > 0) {
      final p = 1 - _hop / _hopTime;
      jump = -sin(p * pi) * 16;
      squash = p < 0.15 || p > 0.85 ? 0.12 : -0.06;
    }

    // Throwing: lean back, then forward.
    var lean = 0.0;
    if (_throw > 0) {
      final p = 1 - _throw / _throwTime;
      lean = p < 0.4 ? -0.25 * (p / 0.4) : 0.3 * (1 - p);
    }

    final face =
        _hop > 0
            ? TeddyFace.happy
            : isSafe
            ? TeddyFace.oh
            : TeddyFace.smile;
    final arms =
        _throw > 0 || _hop > 0
            ? 1.0
            : isMoving
            ? walkCycle * 0.3
            : 0.0;

    canvas.save();
    // Pivot around his feet.
    canvas.translate(38, 76 + jump + bounce);
    canvas.rotate(tilt + lean);
    canvas.scale(1 + squash + breathe, 1 - squash - breathe);
    canvas.translate(-38, -76);

    paintTeddy(
      canvas,
      colour.fur,
      look: _look,
      blink: _blink > 0,
      face: face,
      step: isMoving ? walkCycle : 0,
      arms: arms,
    );
    if (hasHat) _paintHat(canvas, tilt);
    canvas.restore();
  }

  void _paintHat(Canvas canvas, double tilt) {
    // Drops onto his head with a springy bounce.
    var drop = 0.0;
    var stretch = 1.0;
    if (_hatDrop > 0) {
      final p = 1 - _hatDrop / _hatDropTime;
      drop = -50 * (1 - Curves.bounceOut.transform(p));
      stretch = 1 + 0.15 * sin(p * pi);
    }
    // Sways a little behind his waddle, and tips now and then.
    final sway = -tilt * 0.8 + sin(_time * 1.3) * 0.08;
    canvas.save();
    canvas.translate(38, 10 + drop);
    canvas.rotate(sway);
    canvas.scale(stretch, 2 - stretch);
    paintHat(canvas, Offset.zero, scale: 0.9);
    canvas.restore();
  }
}
