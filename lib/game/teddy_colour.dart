import 'dart:math';
import 'dart:ui';

/// The colours a player can choose. Each player picks their own character
/// and colour, so they can find themselves on the leaderboard without
/// reading.
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

/// Who you play as (kid's pick: dinosaurs, bears and chickens).
enum Critter {
  bear('🐻', 10),
  dino('🦖', 8),
  chicken('🐔', 16);

  const Critter(this.emoji, this.hatY);

  final String emoji;

  /// Where a hat sits on this critter's head, in its 76 x 76 box.
  final double hatY;
}

/// The hero's face.
enum TeddyFace {
  /// A little smile.
  smile,

  /// Eyes squeezed into happy arches and a big open grin.
  happy,

  /// "Oh!" Surprised round mouth.
  oh,
}

const _darkColour = Color(0xFF3B2314);

/// Draws the hero (a bear unless [critter] says otherwise) in a 76 x 76 box.
///
/// [look] nudges the eyes (each part -1..1), [blink] closes them, [face]
/// changes the expression, [step] moves the feet (-1..1) and [arms] lifts
/// the arms or wings (-1 down .. 1 up, waving).
void paintTeddy(
  Canvas canvas,
  Color furColour, {
  Critter critter = Critter.bear,
  Offset look = Offset.zero,
  bool blink = false,
  TeddyFace face = TeddyFace.smile,
  double step = 0,
  double arms = 0,
}) {
  switch (critter) {
    case Critter.bear:
      _paintBear(canvas, furColour, step: step, arms: arms);
      _paintEyes(canvas, 24, look: look, blink: blink, face: face);
      // Nose and mouth.
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(38, 32), width: 9, height: 6),
        Paint()..color = _darkColour,
      );
      _paintMouth(canvas, const Offset(38, 36), face);
    case Critter.dino:
      _paintDino(canvas, furColour, step: step, arms: arms);
      _paintEyes(canvas, 22, look: look, blink: blink, face: face);
      _paintMouth(canvas, const Offset(38, 39), face);
    case Critter.chicken:
      _paintChicken(canvas, furColour, step: step, arms: arms, face: face);
      _paintEyes(canvas, 30, look: look, blink: blink, face: face);
  }
}

Paint _fill(Color colour) => Paint()..color = colour;

Color _lighter(Color c, double amount) =>
    Color.lerp(c, const Color(0xFFFFFFFF), amount)!;

Color _darker(Color c, double amount) =>
    Color.lerp(c, const Color(0xFF000000), amount)!;

void _paintCheeks(Canvas canvas, double y) {
  final cheek = _fill(const Color(0x55FF6F91));
  canvas.drawCircle(Offset(24, y), 4, cheek);
  canvas.drawCircle(Offset(52, y), 4, cheek);
}

void _paintBear(
  Canvas canvas,
  Color furColour, {
  required double step,
  required double arms,
}) {
  final fur = _fill(furColour);
  final light = _fill(const Color(0xFFF3DCC2));
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
  // Head and muzzle.
  canvas.drawCircle(const Offset(38, 28), 21, fur);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(38, 36), width: 22, height: 15),
    light,
  );
  _paintCheeks(canvas, 32);
}

void _paintDino(
  Canvas canvas,
  Color skinColour, {
  required double step,
  required double arms,
}) {
  final skin = _fill(skinColour);
  final spikes = _fill(_darker(skinColour, 0.25));
  final belly = _fill(const Color(0xFFFFF3C4));
  final snout = _fill(_lighter(skinColour, 0.35));
  final dark = _fill(_darkColour);
  // A chunky tail poking out to the side.
  canvas.drawPath(
    Path()
      ..moveTo(50, 52)
      ..quadraticBezierTo(70, 56, 74, 70)
      ..quadraticBezierTo(62, 68, 50, 66)
      ..close(),
    skin,
  );
  // Feet and little arms.
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(28, 70 - 3 * max(0, step)),
      width: 16,
      height: 10,
    ),
    skin,
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(48, 70 - 3 * max(0, -step)),
      width: 16,
      height: 10,
    ),
    skin,
  );
  canvas.drawCircle(Offset(20 - 2 * arms.abs(), 50 - 8 * arms), 5, skin);
  canvas.drawCircle(Offset(56 + 2 * arms.abs(), 50 - 8 * arms), 5, skin);
  // Body and belly.
  canvas.drawCircle(const Offset(38, 54), 19, skin);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(38, 57), width: 20, height: 24),
    belly,
  );
  // Spikes along the top of the head.
  for (final x in const [24.0, 38.0, 52.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(x - 7, 14)
        ..lineTo(x, x == 38 ? -2 : 2)
        ..lineTo(x + 7, 14)
        ..close(),
      spikes,
    );
  }
  // Head and a big friendly snout with nostrils.
  canvas.drawCircle(const Offset(38, 27), 20, skin);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(38, 36), width: 28, height: 17),
    snout,
  );
  canvas.drawCircle(const Offset(33, 32), 1.8, dark);
  canvas.drawCircle(const Offset(43, 32), 1.8, dark);
  _paintCheeks(canvas, 31);
}

void _paintChicken(
  Canvas canvas,
  Color featherColour, {
  required double step,
  required double arms,
  required TeddyFace face,
}) {
  final feathers = _fill(featherColour);
  final wing = _fill(_darker(featherColour, 0.12));
  final chest = _fill(_lighter(featherColour, 0.45));
  final red = _fill(const Color(0xFFE53935));
  final orange = _fill(const Color(0xFFFF9800));
  final legs =
      Paint()
        ..color = const Color(0xFFFF9800)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
  // Skinny legs with three toes each.
  for (final (x, lift) in [(30.0, max(0.0, step)), (46.0, max(0.0, -step))]) {
    final foot = Offset(x, 74 - 3 * lift);
    canvas.drawLine(Offset(x, 64), foot, legs);
    for (final dx in const [-5.0, 0.0, 5.0]) {
      canvas.drawLine(foot, foot + Offset(dx, 2), legs);
    }
  }
  // Comb on top.
  for (final (x, y) in const [(32.0, 18.0), (38.0, 14.0), (44.0, 18.0)]) {
    canvas.drawCircle(Offset(x, y), 5, red);
  }
  // Wings that flap when waving.
  for (final side in const [-1.0, 1.0]) {
    canvas.save();
    canvas.translate(38 + side * 22, 48);
    canvas.rotate(side * (0.3 + 0.6 * arms));
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 12, height: 22),
      wing,
    );
    canvas.restore();
  }
  // Round fluffy body.
  canvas.drawCircle(const Offset(38, 46), 25, feathers);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(38, 56), width: 28, height: 20),
    chest,
  );
  _paintCheeks(canvas, 38);
  // Beak: shut when smiling, open when happy or surprised.
  final open = face == TeddyFace.smile ? 0.0 : 4.0;
  canvas.drawPath(
    Path()
      ..moveTo(32, 35)
      ..lineTo(44, 35)
      ..lineTo(38, 40)
      ..close(),
    orange,
  );
  canvas.drawPath(
    Path()
      ..moveTo(33, 40 + open)
      ..lineTo(43, 40 + open)
      ..lineTo(38, 44 + open)
      ..close(),
    orange,
  );
  // Wobbly wattle.
  canvas.drawOval(
    Rect.fromCenter(center: Offset(38, 47 + open), width: 5, height: 7),
    red,
  );
}

void _paintEyes(
  Canvas canvas,
  double y, {
  required Offset look,
  required bool blink,
  required TeddyFace face,
}) {
  final dark = _fill(_darkColour);
  final line =
      Paint()
        ..color = _darkColour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
  final eyeShift = Offset(look.dx * 1.8, look.dy * 1.5);
  for (final eye in [Offset(30, y), Offset(46, y)]) {
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
        _fill(const Color(0xFFFFFFFF)),
      );
    }
  }
}

void _paintMouth(Canvas canvas, Offset centre, TeddyFace face) {
  final dark = _fill(_darkColour);
  switch (face) {
    case TeddyFace.smile:
      canvas.drawArc(
        Rect.fromCenter(center: centre, width: 10, height: 7),
        0.2,
        pi - 0.4,
        false,
        Paint()
          ..color = _darkColour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    case TeddyFace.happy:
      canvas.drawArc(
        Rect.fromCenter(center: centre, width: 12, height: 10),
        0,
        pi,
        true,
        dark,
      );
    case TeddyFace.oh:
      canvas.drawOval(
        Rect.fromCenter(
          center: centre + const Offset(0, 3),
          width: 6,
          height: 7,
        ),
        dark,
      );
  }
}
