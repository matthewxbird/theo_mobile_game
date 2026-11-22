import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../game/layout.dart';
import '../game/rules.dart';
import '../game/sfx.dart';
import '../game/teddy_colour.dart';

/// The magic trick: 4 honey pots fly out of the honey button (counting
/// 1, 2, 3, 4), swirl together, go poof, and out pops a bee that flies
/// over to the bee button.
class HoneyToBee extends StatefulWidget {
  const HoneyToBee({super.key, required this.trigger, required this.critter});

  /// Whose trap turns into whose helper (honey into a bee for bears).
  final Critter critter;

  /// Plays the animation each time this goes up.
  final ValueListenable<int> trigger;

  @override
  State<HoneyToBee> createState() => _HoneyToBeeState();
}

class _HoneyToBeeState extends State<HoneyToBee>
    with SingleTickerProviderStateMixin {
  // Moments in the animation, from 0 (start) to 1 (bee lands).
  static const _potsArrive = 0.3;
  static const _poof = 0.55;
  static const _beeLeaves = 0.75;
  static const _pots = GameRules.honeyForBeehive;

  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (GameRules.honeyToBeeSeconds * 1000).round(),
    ),
  )..addListener(_onTick);

  bool _buzzed = false;

  @override
  void initState() {
    super.initState();
    widget.trigger.addListener(_play);
  }

  @override
  void dispose() {
    widget.trigger.removeListener(_play);
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _buzzed = false;
    Sfx.magic.play();
    _controller.forward(from: 0);
  }

  void _onTick() {
    if (!_buzzed && _controller.value >= _poof) {
      _buzzed = true;
      Sfx.swarmFor(widget.critter).play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder:
            (context, constraints) => AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (!_controller.isAnimating) return const SizedBox.shrink();
                return Stack(
                  clipBehavior: Clip.none,
                  children: _frame(_controller.value, constraints.biggest),
                );
              },
            ),
      ),
    );
  }

  List<Widget> _frame(double t, Size screen) {
    const m = HudLayout.buttonMargin;
    const s = HudLayout.buttonSize;
    final buttonY = screen.height - m - s / 2;
    final honeyButton = Offset(screen.width - m - s / 2, buttonY);
    final beeButton = Offset(m + s / 2, buttonY);
    final middle = Offset(screen.width / 2, screen.height * 0.45);

    final widgets = <Widget>[];

    // 1. Honey pots fly up and make a circle, then swirl in and shrink.
    if (t < _poof) {
      for (var i = 0; i < _pots; i++) {
        final Offset position;
        final double size;
        if (t < _potsArrive) {
          final start = 0.05 * i;
          final p = Curves.easeOut.transform(
            ((t - start) / (_potsArrive - start)).clamp(0.0, 1.0),
          );
          if (p == 0) continue;
          final spot = middle + _polar(90, i * 2 * pi / _pots - pi / 2);
          position =
              Offset.lerp(honeyButton, spot, p)! - Offset(0, sin(p * pi) * 100);
          size = 50 + 20 * p;
        } else {
          final p = (t - _potsArrive) / (_poof - _potsArrive);
          final spin = p * p * 3 * pi;
          final radius = 90 * (1 - Curves.easeIn.transform(p));
          position =
              middle + _polar(radius, i * 2 * pi / _pots - pi / 2 + spin);
          size = 70 - 40 * p;
        }
        widgets.add(_emoji(widget.critter.trap, position, size));
        widgets.add(
          _number(i + 1, position + Offset(size * 0.35, -size * 0.35)),
        );
      }
    }

    // 2. Poof! A flash and a burst of sparkles.
    if (t >= _poof - 0.04 && t < _poof + 0.2) {
      final p = ((t - (_poof - 0.04)) / 0.24).clamp(0.0, 1.0);
      widgets.add(
        Positioned(
          left: middle.dx - 90 * p,
          top: middle.dy - 90 * p,
          child: Container(
            width: 180 * p,
            height: 180 * p,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(255, 255, 200, 0.9 * (1 - p)),
            ),
          ),
        ),
      );
      for (var i = 0; i < 8; i++) {
        final spot = middle + _polar(40 + 120 * p, i * pi / 4);
        widgets.add(_emoji('✨', spot, 40 * (1 - p * 0.5), opacity: 1 - p));
      }
    }

    // 3. A bee pops out, wiggles, then zooms to the bee button.
    if (t >= _poof) {
      final wiggle = sin(t * 60) * 0.25;
      if (t < _beeLeaves) {
        final p = (t - _poof) / (_beeLeaves - _poof);
        final size = 130 * Curves.elasticOut.transform(p);
        widgets.add(
          _emoji(widget.critter.swarm, middle, size, rotation: wiggle),
        );
      } else {
        final p = Curves.easeInOut.transform(
          (t - _beeLeaves) / (1 - _beeLeaves),
        );
        final position =
            Offset.lerp(middle, beeButton, p)! - Offset(0, sin(p * pi) * 140);
        widgets.add(
          _emoji(
            widget.critter.swarm,
            position,
            130 - 70 * p,
            rotation: wiggle,
          ),
        );
      }
    }

    return widgets;
  }

  static Offset _polar(double radius, double angle) =>
      Offset(cos(angle) * radius, sin(angle) * radius);

  static Widget _emoji(
    String emoji,
    Offset center,
    double size, {
    double rotation = 0,
    double opacity = 1,
  }) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: rotation,
          child: FittedBox(child: Text(emoji)),
        ),
      ),
    );
  }

  /// A little counting badge (1, 2, 3, 4) on each honey pot.
  static Widget _number(int n, Offset center) {
    const size = 30.0;
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF8D5524),
        ),
        child: Text(
          '$n',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
