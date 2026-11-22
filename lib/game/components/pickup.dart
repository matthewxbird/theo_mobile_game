import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

/// Something Teddy picks up by walking over it. Pops in and pops out.
abstract class Pickup extends PositionComponent {
  Pickup({required super.position, required double size})
    : super(size: Vector2.all(size), anchor: Anchor.center, priority: 1);

  double _time = 0;
  bool collected = false;

  void collect() {
    if (collected) return;
    collected = true;
    add(ScaleEffect.to(Vector2.all(1.8), EffectController(duration: 0.18)));
    add(RemoveEffect(delay: 0.18));
  }

  @override
  Future<void> onLoad() async {
    scale.setAll(0);
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.4, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // Gentle wiggle so it catches the eye.
    if (!collected) angle = sin(_time * 3) * 0.15;
  }
}
