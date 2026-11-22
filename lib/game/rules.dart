import 'dart:math';

/// All the numbers that make the game easy (or hard) live here.
class GameRules {
  static const teddySpeed = 230.0;

  static const startingHoney = 3;
  static const maxHoney = 5;
  static const honeyJarInterval = 12.0;

  static const sweetsOnScreen = 3;
  static const maxSweetsDroppedOnCatch = 3;
  static const safeSecondsAfterCatch = 2.0;

  static const maxMonsters = 3;
  static const firstMonsterDelay = 3.0;
  static const monsterRespawnDelay = 3.0;
  static const minMonsterSpawnDistance = 250.0;

  /// Start with one monster and add another every 10 sweets, up to the max.
  static int monstersFor(int score) => min(maxMonsters, 1 + score ~/ 10);

  /// Monsters speed up slowly but are always much slower than Teddy.
  static double monsterSpeedFor(int score) =>
      min(teddySpeed * 0.55, 70.0 + 5.0 * (score ~/ 5));

  /// When caught, Teddy drops a few sweets but the score never goes below 0.
  static int sweetsDroppedOnCatch(int score) =>
      min(maxSweetsDroppedOnCatch, score);
}
