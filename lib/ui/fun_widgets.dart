import 'dart:math';

import 'package:flutter/widgets.dart';

import '../game/sfx.dart';
import '../game/teddy_colour.dart';

const brown = Color(0xFF5D3A1A);

/// A teddy picture for menus. Set [dancing] to make him boogie.
class TeddyPicture extends StatefulWidget {
  const TeddyPicture({
    super.key,
    required this.colour,
    this.size = 76,
    this.dancing = false,
  });

  final TeddyColour colour;
  final double size;
  final bool dancing;

  @override
  State<TeddyPicture> createState() => _TeddyPictureState();
}

class _TeddyPictureState extends State<TeddyPicture>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.dancing) _controller.repeat();
  }

  @override
  void didUpdateWidget(TeddyPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dancing && !_controller.isAnimating) _controller.repeat();
    if (!widget.dancing && _controller.isAnimating) _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * pi;
        final wiggle = widget.dancing ? sin(t) * 0.18 : 0.0;
        final hop =
            widget.dancing ? -sin(t * 2).abs() * widget.size * 0.12 : 0.0;
        return Transform.translate(
          offset: Offset(0, hop),
          child: Transform.rotate(
            angle: wiggle,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _TeddyPainter(
                widget.colour,
                // Dancing teddies wave their arms and grin.
                arms: widget.dancing ? sin(t * 2) : 0,
                step: widget.dancing ? sin(t * 2) : 0,
                happy: widget.dancing,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TeddyPainter extends CustomPainter {
  _TeddyPainter(
    this.colour, {
    this.arms = 0,
    this.step = 0,
    this.happy = false,
  });

  final TeddyColour colour;
  final double arms;
  final double step;
  final bool happy;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 76);
    paintTeddy(
      canvas,
      colour.fur,
      arms: arms,
      step: step,
      face: happy ? TeddyFace.happy : TeddyFace.smile,
    );
  }

  @override
  bool shouldRepaint(_TeddyPainter oldDelegate) =>
      oldDelegate.colour != colour ||
      oldDelegate.arms != arms ||
      oldDelegate.step != step ||
      oldDelegate.happy != happy;
}

/// A big, chunky, gently pulsing button that's hard to miss.
class PulsingButton extends StatefulWidget {
  const PulsingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = const Color(0xFF43A047),
  });

  final Widget child;
  final VoidCallback onPressed;
  final Color color;

  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);
  bool _pressed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Sfx.tap.play();
        widget.onPressed();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse =
              1 + 0.07 * Curves.easeInOut.transform(_controller.value);
          return Transform.scale(scale: _pressed ? 0.9 : pulse, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: const Color(0xFFFFFFFF), width: 6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFFFFF),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Colourful confetti falling down the screen, forever.
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  final _pieces = List.generate(70, (i) => _Piece(Random(i)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder:
            (context, _) => CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(_pieces, _controller.value),
            ),
      ),
    );
  }
}

class _Piece {
  _Piece(Random random)
    : x = random.nextDouble(),
      start = random.nextDouble(),
      speed = 0.6 + random.nextDouble() * 0.8,
      spin = random.nextDouble() * 10,
      sway = random.nextDouble() * 2 * pi,
      color = _colors[random.nextInt(_colors.length)];

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFFFFB300),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFEC407A),
  ];

  final double x;
  final double start;
  final double speed;
  final double spin;
  final double sway;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final y = ((p.start + t * p.speed) % 1.2 - 0.1) * size.height;
      final x = p.x * size.width + sin(t * 2 * pi * 2 + p.sway) * 20;
      paint.color = p.color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.spin * 2 * pi);
      canvas.drawRect(const Rect.fromLTWH(-6, -4, 12, 8), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Pops its child in with a bounce after [delay].
class PopIn extends StatelessWidget {
  const PopIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final total = delay + const Duration(milliseconds: 600);
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, t, child) {
        final local = ((t - start) / (1 - start)).clamp(0.0, 1.0);
        final scale = Curves.elasticOut.transform(local);
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }
}
