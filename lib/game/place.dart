import 'dart:ui';

import 'rules.dart';

/// Where Teddy is playing. It changes every few levels.
enum Place {
  meadow('🌼', Color(0xFFB7E4A0)),
  beach('🏖️', Color(0xFFF6E3B4)),
  snow('❄️', Color(0xFFE6F1FA)),
  night('🌙', Color(0xFF2C3E66));

  const Place(this.emoji, this.ground);

  /// Shown in the "Get ready" countdown so you know where you are.
  final String emoji;

  /// The colour of the floor.
  final Color ground;

  /// Meadow for levels 1-3, beach for 4-6, snow for 7-9, night for 10-12,
  /// then round again.
  static Place forLevel(int level) =>
      values[((level - 1) ~/ GameRules.levelsPerPlace) % values.length];
}
