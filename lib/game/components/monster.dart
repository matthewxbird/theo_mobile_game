import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/animation.dart';

import '../rules.dart';
import '../sfx.dart';
import '../teddy_game.dart';
import 'hat.dart';

/// The kinds of bad guys.
enum EnemyKind {
  /// A silly, grumpy blob that walks.
  blob,

  /// A bad bat that flaps and swoops in a wavy line.
  bat,
}

/// A bad guy that slowly comes after Teddy: a grumpy monster or a bad bat.
class Monster extends PositionComponent with HasGameReference<TeddyGame> {
  Monster({
    required super.position,
    required Color color,
    this.kind = EnemyKind.blob,
  }) : _body = Paint()..color = color,
       _wing =
           Paint()..color = Color.lerp(color, const Color(0xFF000000), 0.3)!,
       super(size: Vector2.all(64), anchor: Anchor.center, priority: 2);

  final EnemyKind kind;
  final Paint _wing;

  static const _slipWobbleTime = 0.6;
  static const _slipShrinkTime = 0.3;
  static const _flashTime = 0.8;
  static const _fadeOutTime = 0.5;
  static const _bounceTime = 0.35;
  static const _panicSpeed = 320.0;
  static const _bounceSpeed = 260.0;

  static final _white = Paint()..color = const Color(0xFFFFFFFF);
  static final _dark = Paint()..color = const Color(0xFF2B2B2B);
  static final _brow =
      Paint()
        ..color = const Color(0xFF2B2B2B)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
  static final _drool = Paint()..color = const Color(0xCCB3E5FC);
  static final _frown =
      Paint()
        ..color = const Color(0xFF2B2B2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

  static const _emergeTime = 0.7;
  static const _closeDistance = 140.0;
  static final _sting = Paint()..color = const Color(0xFFE53935);
  static final _dizzy = Paint()..color = const Color(0xFFFFEB3B);
  static final _dust = Paint();

  final _random = Random();
  double _emergeLeft = _emergeTime;
  double _blinkIn = 1 + Random().nextDouble() * 3;
  double _blink = 0;
  Offset _look = Offset.zero;

  final Paint _body;
  double speed = 70;
  double _time = 0;
  double _slipTime = 0;
  bool _slipping = false;
  double _fadeTime = 0;
  bool _fading = false;
  double _bounceLeft = 0;
  Vector2 _bounceDirection = Vector2(1, 0);
  double _munchLeft = 0;

  /// How many lollipops' worth of fat this monster is carrying.
  /// It slowly wears off, and fat monsters are slow.
  double fatness = 0;

  /// Seconds since this monster last ate. Hungry monsters speed up.
  double secondsHungry = 0;

  /// Hat over its eyes: running away in a panic, off the screen.
  bool _blinded = false;
  Vector2 _runDirection = Vector2(1, 0);

  /// Chasing monsters can catch Teddy, fall into honey and get stung.
  bool get isChasing => !_slipping && !_fading && !_blinded;

  /// Teddy's hat lands over its eyes! It can't see, so it runs off screen.
  void coverEyesWithHat() {
    if (!isChasing) return;
    _blinded = true;
    // Run towards the nearest side of the screen, away from Teddy.
    final screen = game.size;
    final exits = [
      (position.x, Vector2(-1, 0)),
      (screen.x - position.x, Vector2(1, 0)),
      (position.y, Vector2(0, -1)),
      (screen.y - position.y, Vector2(0, 1)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    _runDirection = exits.first.$2;
    Sfx.yikes.play();
  }

  /// Can catch Teddy: chasing, and finished popping out of the ground.
  bool get canCatch => isChasing && _emergeLeft <= 0;

  bool get _isHungry => secondsHungry > GameRules.hungerSeconds / 2;
  bool get _isStarving => secondsHungry > GameRules.hungerSeconds;
  bool get _isCloseToTeddy =>
      isChasing &&
      _emergeLeft <= 0 &&
      position.distanceTo(game.teddy.position) < _closeDistance;

  /// Nom nom! Gobble a stolen lollipop and get fatter.
  void eat() {
    if (!isChasing) return;
    fatness = min(GameRules.maxFatness, fatness + 1);
    secondsHungry = 0;
    _munchLeft = 0.8;
    Sfx.munch.play();
  }

  /// Whoops! Slip over in the honey and disappear.
  void slip() {
    if (isChasing) _slipping = true;
  }

  /// Stung by bees (or the level is over): flash, then fade away.
  void flashAndFade() {
    if (isChasing) _fading = true;
  }

  /// Bounce back a little after catching Teddy.
  void bounceAwayFrom(Vector2 point) {
    final away = position - point;
    _bounceDirection = away.length2 > 0 ? away.normalized() : Vector2(1, 0);
    _bounceLeft = _bounceTime;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    if (_slipping) {
      _slipTime += dt;
      angle = sin(_slipTime * 25) * 0.6;
      final shrink = (_slipTime - _slipWobbleTime) / _slipShrinkTime;
      if (shrink > 0) scale.setAll(max(0, 1 - shrink));
      if (shrink >= 1) removeFromParent();
      return;
    }

    if (_fading) {
      _fadeTime += dt;
      if (_fadeTime >= _flashTime + _fadeOutTime) removeFromParent();
      return;
    }

    if (_blinded) {
      // Zig-zag panic run until it's off the screen.
      final sideways = Vector2(-_runDirection.y, _runDirection.x);
      position
        ..add(_runDirection * (_panicSpeed * dt))
        ..add(sideways * (cos(_time * 14) * 120 * dt));
      angle = sin(_time * 20) * 0.2;
      final screen = game.size;
      if (position.x < -size.x ||
          position.y < -size.y ||
          position.x > screen.x + size.x ||
          position.y > screen.y + size.y) {
        removeFromParent();
      }
      return;
    }

    // Eyes follow Teddy, and blink now and then.
    final toTeddyNow = game.teddy.position - position;
    final wantLook =
        toTeddyNow.length2 > 0
            ? Offset(toTeddyNow.normalized().x, toTeddyNow.normalized().y)
            : Offset.zero;
    _look = Offset.lerp(_look, wantLook, min(1, dt * 6))!;
    if (_blink > 0) {
      _blink -= dt;
    } else {
      _blinkIn -= dt;
      if (_blinkIn <= 0) {
        _blink = 0.15;
        _blinkIn = 2 + _random.nextDouble() * 3;
      }
    }

    // Popping out of the ground: stand still until fully out.
    if (_emergeLeft > 0) {
      _emergeLeft -= dt;
      return;
    }

    fatness = max(0, fatness - dt / GameRules.fatWearOffSeconds);
    secondsHungry += dt;
    if (_munchLeft > 0) _munchLeft -= dt;

    if (_bounceLeft > 0) {
      _bounceLeft -= dt;
      position.add(_bounceDirection * (_bounceSpeed * dt));
      position.setFrom(game.clampToField(position));
      return;
    }

    final toTeddy = game.teddy.position - position;
    if (toTeddy.length > 1) {
      final direction = toTeddy.normalized();
      position.add(direction * (speed * dt));
      if (kind == EnemyKind.bat) {
        // Bats swoop from side to side as they fly.
        final sideways = Vector2(-direction.y, direction.x);
        position.add(sideways * (cos(_time * 3) * 70 * dt));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_fading) {
      // Flash on and off, then fade out.
      if (_fadeTime < _flashTime) {
        if ((_fadeTime * 12).floor().isOdd) return;
        _draw(canvas);
        return;
      }
      final opacity = 1 - (_fadeTime - _flashTime) / _fadeOutTime;
      canvas.saveLayer(
        null,
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity.clamp(0.0, 1.0)),
      );
      _draw(canvas);
      canvas.restore();
      return;
    }
    _draw(canvas);
  }

  void _draw(Canvas canvas) {
    final close = _isCloseToTeddy;
    final gloating = _bounceLeft > 0;

    // Popping up out of the ground in a puff of dust.
    var emerge = 1.0;
    if (_emergeLeft > 0) {
      final p = 1 - _emergeLeft / _emergeTime;
      if (kind == EnemyKind.blob) _drawDust(canvas, p);
      emerge = Curves.elasticOut.transform(p);
    }

    canvas.save();
    // Squishy walk: slow and wobbly when fat, quick and jittery when hungry,
    // frantic when close to Teddy or running away blind.
    final wobbleSpeed =
        _blinded
            ? 30.0
            : 10 /
                (1 + 0.5 * fatness) *
                (_isHungry ? 1.8 : 1) *
                (close ? 1.6 : 1);
    final walking = isChasing || _blinded;
    final walkCycle = sin(_time * wobbleSpeed);
    final squish = walking ? walkCycle * 0.06 : 0.0;
    // Fat monsters waddle side to side; close ones lean in for the grab.
    final waddle =
        isChasing ? sin(_time * wobbleSpeed / 2) * 0.04 * (1 + fatness) : 0.0;
    final lean = close ? _look.dx.sign * 0.14 : 0.0;
    // A starving monster's tummy rumbles and shakes it.
    final rumble =
        _isStarving && isChasing ? (_random.nextDouble() - 0.5) * 3 : 0.0;
    // Fat monsters get wider (and a bit taller), growing from their feet.
    final wide = 1 + 0.28 * fatness;
    final tall = 1 + 0.12 * fatness;
    canvas.translate(32 + rumble, 64);
    canvas.rotate(waddle + lean);
    canvas.scale(wide * (1 - squish) * emerge, tall * (1 + squish) * emerge);
    canvas.translate(-32, -64);

    if (kind == EnemyKind.bat) {
      _drawBatBody(canvas);
    } else {
      // Feet take turns stepping, then the body.
      final double stepL = walking ? 3 * max(0.0, walkCycle) : 0.0;
      final double stepR = walking ? 3 * max(0.0, -walkCycle) : 0.0;
      canvas.drawOval(Rect.fromLTWH(12, 52 - stepL, 16, 10), _body);
      canvas.drawOval(Rect.fromLTWH(36, 52 - stepR, 16, 10), _body);
      canvas.drawCircle(const Offset(32, 34), 26, _body);
    }

    // Stung: little red bumps.
    if (_fading) {
      for (final bump in const [
        Offset(14, 40),
        Offset(48, 22),
        Offset(44, 50),
      ]) {
        canvas.drawCircle(bump, 3.5, _sting);
      }
    }

    _drawEyes(canvas, close: close, gloating: gloating);

    // Eyebrows: grumpy, or extra fierce up close.
    if (close && !_blinded) {
      canvas.drawLine(const Offset(13, 16), const Offset(28, 25), _brow);
      canvas.drawLine(const Offset(51, 16), const Offset(36, 25), _brow);
    } else {
      canvas.drawLine(const Offset(14, 19), const Offset(28, 24), _brow);
      canvas.drawLine(const Offset(50, 19), const Offset(36, 24), _brow);
    }

    if (_slipping) {
      // Dizzy stars circle its head.
      for (var i = 0; i < 3; i++) {
        final a = _slipTime * 8 + i * 2 * pi / 3;
        final spot = const Offset(32, 6) + Offset(cos(a) * 20, sin(a) * 6);
        canvas.drawPath(starPath(spot, 5), _dizzy);
      }
    }

    if (_blinded) {
      // A wobbly "Oh no!" mouth, and Teddy's hat pulled down over its eyes.
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(32, 48), width: 12, height: 10),
        _dark,
      );
      paintHat(canvas, const Offset(32, 36), scale: 1.25);
    } else if (_munchLeft > 0) {
      // Chomping: mouth opens and shuts.
      final open = (sin(_munchLeft * 30) + 1) / 2;
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(32, 47),
          width: 16,
          height: 3 + 9 * open,
        ),
        _dark,
      );
    } else if (gloating) {
      // A smug, toothy grin after catching Teddy.
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(32, 44), width: 22, height: 14),
        0,
        pi,
        true,
        _dark,
      );
      canvas.drawRect(const Rect.fromLTWH(24, 44, 16, 3), _white);
    } else if (close) {
      // Mouth wide open, teeth showing: "Raaah!"
      final open = 10 + 3 * sin(_time * 12);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(32, 48), width: 20, height: open),
        _dark,
      );
      for (final x in const [25.0, 32.0, 39.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 3, 48 - open / 2)
            ..lineTo(x + 3, 48 - open / 2)
            ..lineTo(x, 48 - open / 2 + 4)
            ..close(),
          _white,
        );
      }
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(32, 48), width: 14, height: 8),
        pi + 0.3,
        pi - 0.6,
        false,
        _frown,
      );
      // Hungry monsters drool.
      if (_isHungry) {
        final drip = 4 + 3 * sin(_time * 4).abs();
        canvas.drawOval(Rect.fromLTWH(36, 48, 5, drip + 3), _drool);
      }
    }

    canvas.restore();
  }

  void _drawEyes(Canvas canvas, {required bool close, required bool gloating}) {
    final eyeSize = close ? 8.5 : 7.0;
    for (final eye in const [Offset(23, 31), Offset(41, 31)]) {
      if (_slipping) {
        // Dizzy X eyes.
        canvas.drawLine(
          eye - const Offset(4, 4),
          eye + const Offset(4, 4),
          _frown,
        );
        canvas.drawLine(
          eye + const Offset(-4, 4),
          eye + const Offset(4, -4),
          _frown,
        );
      } else if (gloating) {
        // Smug squinty eyes.
        canvas.drawArc(
          Rect.fromCenter(
            center: eye + const Offset(0, 2),
            width: 10,
            height: 7,
          ),
          pi + 0.2,
          pi - 0.4,
          false,
          _frown,
        );
      } else if (_blink > 0) {
        canvas.drawLine(
          eye - const Offset(6, 0),
          eye + const Offset(6, 0),
          _frown,
        );
      } else {
        canvas.drawCircle(eye, eyeSize, _white);
        // Pupils watch Teddy.
        canvas.drawCircle(
          eye + Offset(_look.dx * 2.5, _look.dy * 2.5),
          close ? 3 : 3.5,
          _dark,
        );
      }
    }
  }

  /// A bad bat: flapping wings, pointy ears, tiny feet and fangs.
  void _drawBatBody(Canvas canvas) {
    // Bats bob up and down as they flap.
    final flap = sin(_time * 18);
    canvas.translate(0, -6 + sin(_time * 4) * 4);

    // Wings, flapping around the shoulders. Draw the left, then mirror it.
    for (final side in const [1.0, -1.0]) {
      canvas.save();
      canvas.translate(32, 0);
      canvas.scale(side, 1);
      canvas.translate(-32, 0);
      canvas.translate(14, 32);
      canvas.rotate(flap * 0.5);
      canvas.drawPath(_batWing, _wing);
      canvas.restore();
    }
    // Pointy ears.
    for (final side in const [1.0, -1.0]) {
      canvas.save();
      canvas.translate(32, 0);
      canvas.scale(side, 1);
      canvas.translate(-32, 0);
      canvas.drawPath(
        Path()
          ..moveTo(14, 20)
          ..lineTo(15, 2)
          ..lineTo(27, 13)
          ..close(),
        _body,
      );
      canvas.restore();
    }
    // Body and little dangling feet.
    canvas.drawCircle(const Offset(32, 34), 22, _body);
    canvas.drawCircle(const Offset(26, 57), 3, _body);
    canvas.drawCircle(const Offset(38, 57), 3, _body);
    // Fangs.
    for (final x in const [27.0, 37.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 2.5, 50)
          ..lineTo(x + 2.5, 50)
          ..lineTo(x, 55)
          ..close(),
        _white,
      );
    }
  }

  /// One scalloped bat wing, from the shoulder outwards (to the left).
  static final _batWing =
      Path()
        ..moveTo(0, -6)
        ..quadraticBezierTo(-18, -20, -32, -12)
        ..quadraticBezierTo(-28, -2, -24, 4)
        ..quadraticBezierTo(-18, -2, -14, 6)
        ..quadraticBezierTo(-8, 0, -4, 10)
        ..close();

  /// A puff of dust where the monster pops out of the ground.
  void _drawDust(Canvas canvas, double p) {
    _dust.color = Color.fromRGBO(255, 255, 255, 0.7 * (1 - p));
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3;
      final spot =
          const Offset(32, 58) + Offset(cos(a) * 30 * p, sin(a) * 10 * p);
      canvas.drawCircle(spot, 6 + 6 * p, _dust);
    }
  }
}
