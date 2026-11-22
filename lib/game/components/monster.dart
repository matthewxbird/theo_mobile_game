import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../teddy_game.dart';

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
  static const _bounceSpeed = 260.0;

  static final _white = Paint()..color = const Color(0xFFFFFFFF);
  static final _dark = Paint()..color = const Color(0xFF2B2B2B);
  static final _brow = Paint()
    ..color = const Color(0xFF2B2B2B)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;
  static final _frown = Paint()
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

  /// Chasing monsters can catch Teddy, fall into honey and get stung.
  bool get isChasing => !_slipping && !_fading;

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
    // Squishy walk.
    final squish = isChasing ? sin(_time * 10) * 0.05 : 0.0;
    canvas.translate(32, 64);
    canvas.scale(1 - squish, 1 + squish);
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
    // Grumpy eyebrows and frown.
    canvas.drawLine(const Offset(14, 19), const Offset(28, 24), _brow);
    canvas.drawLine(const Offset(50, 19), const Offset(36, 24), _brow);
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(32, 48), width: 14, height: 8),
      pi + 0.3,
      pi - 0.6,
      false,
      _frown,
    );

    canvas.restore();
  }
}
