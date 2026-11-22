// Makes the game's sound effects from simple waves, so we need no sound files
// from anywhere else. Run with: dart run tool/generate_sounds.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const sampleRate = 22050;
const outDir = 'assets/audio';

void main() {
  Directory(outDir).createSync(recursive: true);

  // Teddy picks up a sweet: quick happy "bling" going up.
  write('sweet.wav', notes([1047, 1319, 1568], noteLength: 0.06, tail: 0.15));

  // Teddy picks up a honey jar: longer, rounder tune going up.
  write('jar.wav', notes([523, 659, 784, 1047], noteLength: 0.09, tail: 0.25));

  // Honey dropped on the ground: a sticky "bloop" going down.
  write('honey.wav', sweep(from: 620, to: 180, seconds: 0.22, volume: 0.7));

  // A monster slips in the honey: "whoooa" up and down, then a pop.
  write('slip.wav', [
    ...whoops(),
    ...pop(),
  ]);

  // A monster catches Teddy: a bouncy "boing".
  write('caught.wav', boing());

  // Level complete: a little fanfare.
  write(
    'levelup.wav',
    notes([523, 659, 784, 1047], noteLength: 0.13, tail: 0.6),
  );

  // The beehive is opened: a swarm of buzzing bees.
  write('buzz.wav', buzz());

  // A bee stings a monster: a quick "zip" up.
  write('sting.wav', sweep(from: 900, to: 1900, seconds: 0.12, volume: 0.5));

  // Countdown "3, 2, 1": a short blip for each number.
  write('tick.wav', notes([880], noteLength: 0.05, tail: 0.12));

  // Countdown "Go!": a bright chord going up.
  write('go.wav', notes([784, 1047, 1568], noteLength: 0.07, tail: 0.35));

  // Tapping a big menu button.
  write('tap.wav', sweep(from: 500, to: 900, seconds: 0.1, volume: 0.5));

  // Honey pots swirl together and turn into a bee: a twinkly magic run up.
  write(
    'magic.wav',
    notes(
      [784, 988, 1175, 1319, 1568, 1976, 2349],
      noteLength: 0.06,
      tail: 0.5,
    ),
  );

  // Teddy puts on a hat: "ta-da!"
  write('tada.wav', notes([784, 1175], noteLength: 0.1, tail: 0.4));

  // Teddy throws his hat: a quick rising whoosh.
  write('whoosh.wav', whoosh());

  // A monster gets a hat over its eyes: "yikes!" wobbling up and away.
  write('yikes.wav', yikes());

  // A monster eats a stolen lollipop: "nom nom nom".
  write('munch.wav', munch());

  stdout.writeln('Sounds written to $outDir/');
}

List<double> whoosh() {
  final random = Random(11);
  final count = (0.3 * sampleRate).round();
  final out = <double>[];
  var smooth = 0.0;
  var phase = 0.0;
  for (var n = 0; n < count; n++) {
    final p = n / count;
    // Smoothed noise sounds like air rushing past.
    smooth += ((random.nextDouble() * 2 - 1) - smooth) * (0.05 + 0.4 * p);
    phase += 2 * pi * (300 + 900 * p) / sampleRate;
    final loudness = sin(p * pi);
    out.add((0.8 * smooth + 0.15 * sin(phase)) * loudness);
  }
  return out;
}

List<double> yikes() {
  const seconds = 0.5;
  final count = (seconds * sampleRate).round();
  final out = <double>[];
  var phase = 0.0;
  for (var n = 0; n < count; n++) {
    final t = n / sampleRate;
    final p = n / count;
    final f = 700 + 500 * p + 120 * sin(2 * pi * 16 * t);
    phase += 2 * pi * f / sampleRate;
    out.add(0.45 * sin(phase) * envelope(n, count, attack: 0.01));
  }
  return out;
}

List<double> munch() {
  final random = Random(3);
  final out = <double>[];
  for (var chomp = 0; chomp < 3; chomp++) {
    final count = (0.09 * sampleRate).round();
    var phase = 0.0;
    for (var n = 0; n < count; n++) {
      final p = n / count;
      final f = 260 - 120 * p;
      phase += 2 * pi * f / sampleRate;
      final crunch = (random.nextDouble() * 2 - 1) * 0.3;
      out.add((0.6 * sin(phase) + crunch) * pow(1 - p, 2));
    }
    out.addAll(List.filled((0.05 * sampleRate).round(), 0.0));
  }
  return out;
}

List<double> buzz() {
  const seconds = 0.9;
  final count = (seconds * sampleRate).round();
  final out = <double>[];
  var phase = 0.0;
  for (var n = 0; n < count; n++) {
    final t = n / sampleRate;
    final f = 200 + 25 * sin(2 * pi * 6 * t);
    phase += f / sampleRate;
    // A sawtooth wave sounds buzzy; the fast wobble makes it flutter.
    final saw = 2 * (phase - phase.floor()) - 1;
    final flutter = 0.7 + 0.3 * sin(2 * pi * 28 * t);
    out.add(0.35 * saw * flutter * envelope(n, count, attack: 0.05));
  }
  return out;
}

List<double> notes(List<double> frequencies,
    {required double noteLength, required double tail}) {
  final out = <double>[];
  for (var i = 0; i < frequencies.length; i++) {
    final isLast = i == frequencies.length - 1;
    final length = isLast ? noteLength + tail : noteLength;
    final count = (length * sampleRate).round();
    for (var n = 0; n < count; n++) {
      final t = n / sampleRate;
      final f = frequencies[i];
      // A sine with a little octave on top sounds bright, like a toy bell.
      final wave = sin(2 * pi * f * t) + 0.3 * sin(4 * pi * f * t);
      out.add(0.5 * wave * envelope(n, count, attack: 0.005));
    }
  }
  return out;
}

List<double> sweep(
    {required double from,
    required double to,
    required double seconds,
    double volume = 0.6}) {
  final count = (seconds * sampleRate).round();
  final out = <double>[];
  var phase = 0.0;
  for (var n = 0; n < count; n++) {
    final progress = n / count;
    final f = from + (to - from) * progress;
    phase += 2 * pi * f / sampleRate;
    out.add(volume * sin(phase) * envelope(n, count, attack: 0.01));
  }
  return out;
}

List<double> whoops() {
  const seconds = 0.55;
  final count = (seconds * sampleRate).round();
  final out = <double>[];
  var phase = 0.0;
  for (var n = 0; n < count; n++) {
    final p = n / count;
    // Up then down, with a wobble.
    final base = p < 0.4 ? 300 + 600 * (p / 0.4) : 900 - 700 * ((p - 0.4) / 0.6);
    final f = base + 40 * sin(2 * pi * 9 * n / sampleRate);
    phase += 2 * pi * f / sampleRate;
    out.add(0.5 * sin(phase) * envelope(n, count, attack: 0.02));
  }
  return out;
}

List<double> pop() {
  final random = Random(7);
  final count = (0.09 * sampleRate).round();
  final out = <double>[];
  var phase = 0.0;
  for (var n = 0; n < count; n++) {
    final p = n / count;
    final f = 1400 - 1000 * p;
    phase += 2 * pi * f / sampleRate;
    final noise = random.nextDouble() * 2 - 1;
    out.add((0.5 * sin(phase) + 0.25 * noise) * pow(1 - p, 2));
  }
  return out;
}

List<double> boing() {
  const seconds = 0.45;
  final count = (seconds * sampleRate).round();
  final out = <double>[];
  var phase = 0.0;
  for (var n = 0; n < count; n++) {
    final t = n / sampleRate;
    final p = n / count;
    // Wobble that fades out, like a spring.
    final f = 220 + 120 * sin(2 * pi * 14 * t) * (1 - p);
    phase += 2 * pi * f / sampleRate;
    out.add(0.6 * sin(phase) * envelope(n, count, attack: 0.005));
  }
  return out;
}

/// Fade in quickly, fade out smoothly, so there are no clicks.
double envelope(int n, int count, {required double attack}) {
  final attackSamples = max(1, (attack * sampleRate).round());
  if (n < attackSamples) return n / attackSamples;
  final p = (n - attackSamples) / max(1, count - attackSamples);
  return pow(1 - p, 1.5).toDouble();
}

void write(String name, List<double> samples) {
  final data = ByteData(44 + samples.length * 2);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little); // Chunk size.
  data.setUint16(20, 1, Endian.little); // PCM.
  data.setUint16(22, 1, Endian.little); // Mono.
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little); // Bytes per second.
  data.setUint16(32, 2, Endian.little); // Bytes per sample.
  data.setUint16(34, 16, Endian.little); // Bits per sample.
  ascii(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final s = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    data.setInt16(44 + i * 2, s, Endian.little);
  }
  File('$outDir/$name').writeAsBytesSync(data.buffer.asUint8List());
}
