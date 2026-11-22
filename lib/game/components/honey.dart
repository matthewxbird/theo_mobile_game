import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../teddy_colour.dart';
import '../teddy_game.dart';
import 'emoji.dart';
import 'pickup.dart';

/// A pickup that gives the hero another trap to drop: a honey jar for
/// bears, bananas for dinosaurs, an egg for chickens, a bone for dogs.
class HoneyJar extends Pickup with HasGameReference<TeddyGame> {
  HoneyJar({required super.position}) : super(size: 44);

  static final _honey = Paint()..color = const Color(0xFFF2A900);
  static final _lid = Paint()..color = const Color(0xFF8D5524);
  static final _shine = Paint()..color = const Color(0x88FFFFFF);

  @override
  void render(Canvas canvas) {
    if (game.critter != Critter.bear) {
      paintEmoji(canvas, game.critter.trap, const Offset(22, 22), 34);
      return;
    }
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

/// A slippery trap on the ground. The first monster to step on it slips
/// over. Honey for bears, a banana peel for dinosaurs, a splatted egg for
/// chickens, a bone for dogs.
class HoneyPuddle extends PositionComponent with HasGameReference<TeddyGame> {
  HoneyPuddle({required super.position})
    : super(size: Vector2(76, 46), anchor: Anchor.center, priority: 0);

  static final _honey = Paint()..color = const Color(0xDDF5B700);
  static final _shine = Paint()..color = const Color(0x77FFFFFF);
  static final _eggWhite = Paint()..color = const Color(0xEEFFFFFF);
  static final _yolk = Paint()..color = const Color(0xFFFFC107);

  bool used = false;

  /// Single use: shrink away once a monster has slipped on it.
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
    switch (game.critter) {
      case Critter.bear:
        canvas.drawOval(const Rect.fromLTWH(0, 6, 76, 40), _honey);
        canvas.drawOval(const Rect.fromLTWH(10, 0, 34, 24), _honey);
        canvas.drawOval(const Rect.fromLTWH(18, 8, 14, 7), _shine);
      case Critter.chicken:
        // A cracked, splatted egg: gooey white with a yolk in the middle.
        canvas.drawOval(const Rect.fromLTWH(4, 8, 68, 34), _eggWhite);
        canvas.drawOval(const Rect.fromLTWH(14, 2, 30, 22), _eggWhite);
        canvas.drawCircle(const Offset(36, 24), 10, _yolk);
        canvas.drawCircle(const Offset(33, 21), 3, _shine);
      case Critter.dino:
      case Critter.dog:
        // A banana peel or a bone lying on its side.
        canvas.save();
        canvas.translate(38, 26);
        canvas.rotate(game.critter == Critter.dino ? 1.2 : 0.4);
        paintEmoji(canvas, game.critter.trap, Offset.zero, 40);
        canvas.restore();
    }
  }
}
