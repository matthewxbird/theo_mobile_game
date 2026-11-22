import 'dart:math';
import 'dart:ui';

/// Where Teddy is playing. Each level is a surprise new place.
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

  /// A surprise place for the next level: random, but never the same as
  /// [previous], so every level looks different from the last.
  static Place randomAfter(Place? previous, Random random) {
    final choices = values.where((p) => p != previous).toList();
    return choices[random.nextInt(choices.length)];
  }
}
