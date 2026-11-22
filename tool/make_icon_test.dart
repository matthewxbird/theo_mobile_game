// Draws the app icon from the game's own art (happy Teddy in his magic hat,
// holding a lollipop), so the icon always matches the game.
//
// Run with:  flutter test tool/make_icon_test.dart
// then:      dart run flutter_launcher_icons
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theo_mobile_game/game/components/hat.dart';
import 'package:theo_mobile_game/game/components/sweet.dart';
import 'package:theo_mobile_game/game/teddy_colour.dart';

const _size = 1024.0;

Future<void> _drawIcon(String path, {required bool withBackground}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  if (withBackground) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _size, _size),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFFB7E4A0)],
        ).createShader(const Rect.fromLTWH(0, 0, _size, _size)),
    );
    // A few flowers in the grass.
    final petal = Paint()..color = const Color(0xFFFFFFFF);
    final middle = Paint()..color = const Color(0xFFFFD54F);
    for (final c in const [Offset(150, 860), Offset(880, 900), Offset(820, 760)]) {
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * pi / 5;
        canvas.drawCircle(
          c + Offset(28 * cos(a), 28 * sin(a)),
          22,
          petal,
        );
      }
      canvas.drawCircle(c, 18, middle);
    }
  }

  // Android crops adaptive icons to the middle, so the foreground is smaller.
  final scale = withBackground ? 8.6 : 6.4;
  canvas.save();
  // Teddy plus hat spans y = -17 .. 77 in his own 76-wide box.
  canvas.translate(_size / 2 - 38 * scale, _size / 2 - 30 * scale);
  canvas.scale(scale);
  paintTeddy(
    canvas,
    TeddyColour.brown.fur,
    face: TeddyFace.happy,
    arms: 1,
  );
  paintHat(canvas, const Offset(38, 10), scale: 0.9);
  // A lollipop held up in his right paw.
  canvas.save();
  canvas.translate(56, 18);
  canvas.scale(0.75);
  Sweet.paintLolly(canvas, Paint()..color = const Color(0xFFEC407A));
  canvas.restore();
  canvas.restore();

  final image = await recorder.endRecording().toImage(
    _size.toInt(),
    _size.toInt(),
  );
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  test('make app icon', () async {
    await _drawIcon('assets/icon/icon.png', withBackground: true);
    await _drawIcon('assets/icon/icon_foreground.png', withBackground: false);
  });
}
