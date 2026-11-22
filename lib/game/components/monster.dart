import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../rules.dart';
import '../sfx.dart';
import '../teddy_game.dart';
import 'hat.dart';

/// A silly, grumpy blob that slowly walks towards Teddy.
class Monster extends PositionComponent with HasGameReference<TeddyGame> {
  Monster({required super.position, required Color color})
    : _body = Paint()..color = color,
      super(size: Vector2.all(64), anchor: Anchor.center, priority: 2);

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

  bool get _isHungry => secondsHungry > GameRules.hungerSeconds / 2;

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
      position.add(toTeddy.normalized()..scale(speed * dt));
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
    canvas.save();
    // Squishy walk: slow and wobbly when fat, quick and jittery when hungry.
    final wobbleSpeed = 10 / (1 + 0.5 * fatness) * (_isHungry ? 1.8 : 1);
    final squish =
        isChasing || _blinded
            ? sin(_time * (_blinded ? 30 : wobbleSpeed)) * 0.06
            : 0.0;
    // Fat monsters get wider (and a bit taller), growing from their feet.
    final wide = 1 + 0.28 * fatness;
    final tall = 1 + 0.12 * fatness;
    canvas.translate(32, 64);
    canvas.scale(wide * (1 - squish), tall * (1 + squish));
    canvas.translate(-32, -64);

    // Feet and body.
    canvas.drawOval(Rect.fromLTWH(12, 52, 16, 10), _body);
    canvas.drawOval(Rect.fromLTWH(36, 52, 16, 10), _body);
    canvas.drawCircle(const Offset(32, 34), 26, _body);
    // Eyes.
    canvas.drawCircle(const Offset(23, 31), 7, _white);
    canvas.drawCircle(const Offset(41, 31), 7, _white);
    canvas.drawCircle(const Offset(23, 33), 3.5, _dark);
    canvas.drawCircle(const Offset(41, 33), 3.5, _dark);
    // Grumpy eyebrows.
    canvas.drawLine(const Offset(14, 19), const Offset(28, 24), _brow);
    canvas.drawLine(const Offset(50, 19), const Offset(36, 24), _brow);

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
}
