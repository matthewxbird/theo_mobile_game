import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'teddy_colour.dart';

/// The game's sound effects. Files live in assets/audio/ and are made by
/// tool/generate_sounds.dart.
enum Sfx {
  sweet('sweet.wav'),
  jar('jar.wav'),
  honey('honey.wav'),
  slip('slip.wav'),
  caught('caught.wav'),
  levelUp('levelup.wav'),
  buzz('buzz.wav'),
  sting('sting.wav'),
  tick('tick.wav'),
  go('go.wav'),
  tap('tap.wav'),
  munch('munch.wav'),
  magic('magic.wav'),
  tada('tada.wav'),
  whoosh('whoosh.wav'),
  yikes('yikes.wav'),
  cheep('cheep.wav'),
  rawr('rawr.wav'),
  woof('woof.wav');

  /// The sound of this critter's helpers setting off.
  static Sfx swarmFor(Critter critter) => switch (critter) {
    Critter.bear => buzz,
    Critter.dino => rawr,
    Critter.chicken => cheep,
    Critter.dog => woof,
  };

  const Sfx(this.file);

  final String file;

  static final _pools = <Sfx, AudioPool>{};

  /// Load every sound up front so they play straight away.
  static Future<void> load() async {
    for (final sound in values) {
      try {
        _pools[sound] = await FlameAudio.createPool(sound.file, maxPlayers: 3);
      } catch (error) {
        // No sound is better than no game.
        debugPrint('Could not load ${sound.file}: $error');
      }
    }
  }

  void play() {
    final pool = _pools[this];
    if (pool != null) unawaited(pool.start());
  }
}
