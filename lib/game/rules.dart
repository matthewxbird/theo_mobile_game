import 'dart:math';

/// All the numbers that make the game easy (or hard) live here.
class GameRules {
  static const teddySpeed = 230.0;

  static const startingHoney = 3;
  static const maxHoney = 5;
  static const honeyJarInterval = 12.0;

  static const sweetsOnScreen = 3;
  static const sweetsLostOnCatch = 1;
  static const safeSecondsAfterCatch = 2.0;

  static const beehivesPerLevelUp = 1;

  static const maxMonsters = 3;
  static const firstMonsterDelay = 3.0;
  static const monsterRespawnDelay = 3.0;
  static const minMonsterSpawnDistance = 250.0;

  /// Level 1 needs 6 lollipops, and each level after needs 2 more.
  static int sweetsForLevel(int level) => 6 + 2 * (level - 1);

  /// One monster on level 1, one more each level, up to the max.
  static int monstersFor(int level) => min(maxMonsters, level);

  /// Monsters speed up each level but are always much slower than Teddy.
  static double monsterSpeedFor(int level) =>
      min(teddySpeed * 0.55, 70.0 + 8.0 * (level - 1));

  /// When caught, Teddy loses a lollipop, but never goes below 0.
  static int sweetsLostWhenCaught(int collected) =>
      min(sweetsLostOnCatch, collected);
}
