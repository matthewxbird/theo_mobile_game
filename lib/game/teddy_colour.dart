import 'dart:math';
import 'dart:ui';

/// The teddies a player can choose. Each player picks their own colour, so
/// they can find themselves on the leaderboard without reading.
enum TeddyColour {
  brown(Color(0xFFA0642D)),
  pink(Color(0xFFF48FB1)),
  blue(Color(0xFF64B5F6)),
  purple(Color(0xFFB388FF)),
  gold(Color(0xFFFFB300)),
  red(Color(0xFFE57373));

  const TeddyColour(this.fur);

  final Color fur;
}

/// Teddy's face.
enum TeddyFace {
  /// A little smile.
  smile,

  /// Eyes squeezed into happy arches and a big open grin.
  happy,

  /// "Oh!" Surprised round mouth.
  oh,
}

/// Draws a teddy bear in a 76 x 76 box.
///
/// [look] nudges his eyes (each part -1..1), [blink] closes them, [face]
/// changes his expression, [step] moves his feet (-1..1) and [arms] lifts
/// them (-1 down .. 1 up, waving).
void paintTeddy(
  Canvas canvas,
  Color furColour, {
  Offset look = Offset.zero,
  bool blink = false,
  TeddyFace face = TeddyFace.smile,
  double step = 0,
  double arms = 0,
}) {
  final fur = Paint()..color = furColour;
  final light = Paint()..color = const Color(0xFFF3DCC2);
  final dark = Paint()..color = const Color(0xFF3B2314);
  final cheek = Paint()..color = const Color(0x55FF6F91);
  final line =
      Paint()
        ..color = const Color(0xFF3B2314)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

  // Feet (stepping) and arms (swinging or waving).
  canvas.drawCircle(Offset(28, 70 - 3 * max(0, step)), 7, fur);
  canvas.drawCircle(Offset(48, 70 - 3 * max(0, -step)), 7, fur);
  canvas.drawCircle(Offset(17 - 2 * arms.abs(), 50 - 8 * arms), 7, fur);
  canvas.drawCircle(Offset(59 + 2 * arms.abs(), 50 - 8 * arms), 7, fur);
  // Body and belly.
  canvas.drawCircle(const Offset(38, 54), 19, fur);
  canvas.drawCircle(const Offset(38, 57), 11, light);
  // Ears.
  canvas.drawCircle(const Offset(20, 12), 9, fur);
  canvas.drawCircle(const Offset(56, 12), 9, fur);
  canvas.drawCircle(const Offset(20, 12), 5, light);
  canvas.drawCircle(const Offset(56, 12), 5, light);
  // Head.
  canvas.drawCircle(const Offset(38, 28), 21, fur);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(38, 36), width: 22, height: 15),
    light,
  );
  // Rosy cheeks.
  canvas.drawCircle(const Offset(24, 32), 4, cheek);
  canvas.drawCircle(const Offset(52, 32), 4, cheek);
  // Eyes: looking around, blinking, or squeezed shut with joy.
  final eyeShift = Offset(look.dx * 1.8, look.dy * 1.5);
  for (final eye in const [Offset(30, 24), Offset(46, 24)]) {
    if (face == TeddyFace.happy) {
      canvas.drawArc(
        Rect.fromCenter(center: eye + const Offset(0, 1), width: 7, height: 6),
        pi + 0.2,
        pi - 0.4,
        false,
        line,
      );
    } else if (blink) {
      canvas.drawLine(eye - const Offset(3, 0), eye + const Offset(3, 0), line);
    } else {
      canvas.drawCircle(eye + eyeShift, 3, dark);
      // A tiny shine makes the eyes sparkle.
      canvas.drawCircle(
        eye + eyeShift + const Offset(-1, -1),
        1,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }
  }
  // Nose.
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(38, 32), width: 9, height: 6),
    dark,
  );
  // Mouth.
  switch (face) {
    case TeddyFace.smile:
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(38, 36), width: 10, height: 7),
        0.2,
        pi - 0.4,
        false,
        line,
      );
    case TeddyFace.happy:
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(38, 36), width: 12, height: 10),
        0,
        pi,
        true,
        dark,
      );
    case TeddyFace.oh:
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(38, 39), width: 6, height: 7),
        dark,
      );
  }
}
