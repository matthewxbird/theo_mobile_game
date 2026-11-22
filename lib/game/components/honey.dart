import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'pickup.dart';

/// A honey jar. Picking it up gives Teddy another honey pot to drop.
class HoneyJar extends Pickup {
  HoneyJar({required super.position}) : super(size: 44);

  static final _honey = Paint()..color = const Color(0xFFF2A900);
  static final _lid = Paint()..color = const Color(0xFF8D5524);
  static final _shine = Paint()..color = const Color(0x88FFFFFF);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 12, 32, 30),
        const Radius.circular(12),
      ),
      _honey,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(9, 4, 26, 10),
        const Radius.circular(4),
      ),
      _lid,
    );
    canvas.drawOval(const Rect.fromLTWH(12, 18, 7, 12), _shine);
  }
}

/// A sticky puddle. The first monster to step in it slips over.
class HoneyPuddle extends PositionComponent {
  HoneyPuddle({required super.position})
      : super(size: Vector2(76, 46), anchor: Anchor.center, priority: 0);

  static final _honey = Paint()..color = const Color(0xDDF5B700);
  static final _shine = Paint()..color = const Color(0x77FFFFFF);

  bool used = false;

  /// Single use: shrink away once a monster has slipped in it.
  void use() {
    if (used) return;
    used = true;
    add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.4)));
    add(RemoveEffect(delay: 0.4));
  }

  @override
  Future<void> onLoad() async {
    scale.setAll(0.3);
    add(ScaleEffect.to(Vector2.all(1), EffectController(duration: 0.2)));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawOval(const Rect.fromLTWH(0, 6, 76, 40), _honey);
    canvas.drawOval(const Rect.fromLTWH(10, 0, 34, 24), _honey);
    canvas.drawOval(const Rect.fromLTWH(18, 8, 14, 7), _shine);
  }
}
