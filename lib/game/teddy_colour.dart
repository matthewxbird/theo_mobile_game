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

/// Draws a teddy bear in a 76 x 76 box.
void paintTeddy(Canvas canvas, Color furColour) {
  final fur = Paint()..color = furColour;
  final light = Paint()..color = const Color(0xFFF3DCC2);
  final dark = Paint()..color = const Color(0xFF3B2314);
  final smile =
      Paint()
        ..color = const Color(0xFF3B2314)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

  // Feet and arms.
  canvas.drawCircle(const Offset(28, 70), 7, fur);
  canvas.drawCircle(const Offset(48, 70), 7, fur);
  canvas.drawCircle(const Offset(17, 50), 7, fur);
  canvas.drawCircle(const Offset(59, 50), 7, fur);
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
  // Face.
  canvas.drawCircle(const Offset(30, 24), 3, dark);
  canvas.drawCircle(const Offset(46, 24), 3, dark);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(38, 32), width: 9, height: 6),
    dark,
  );
  canvas.drawArc(
    Rect.fromCenter(center: const Offset(38, 36), width: 10, height: 7),
    0.2,
    pi - 0.4,
    false,
    smile,
  );
}
