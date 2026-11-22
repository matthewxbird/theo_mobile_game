import 'dart:math';

/// All the numbers that make the game easy (or hard) live here.
class GameRules {
  static const teddySpeed = 230.0;

  static const startingHoney = 3;

  /// Collecting this many honey pots turns them into one beehive.
  static const honeyForBeehive = 4;

  /// How long the honey-to-bee animation takes before the bee arrives.
  static const honeyToBeeSeconds = 1.8;
  static const honeyJarInterval = 12.0;

  /// Hats are special: one turns up this often, and only when Teddy has no
  /// hat and there isn't one on the floor or flying already.
  static const hatInterval = 25.0;

  /// Tap this close to Teddy to throw his hat.
  static const hatTapDistance = 60.0;

  static const sweetsOnScreen = 3;
  static const sweetsLostOnCatch = 1;
  static const safeSecondsAfterCatch = 2.0;

  static const beehivesPerLevelUp = 1;

  static const maxMonsters = 3;

  /// How often a new bad guy is a bad bat instead of a grumpy monster.
  static const batChance = 0.4;
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

  /// Each stolen lollipop makes a monster one step fatter, up to this.
  static const maxFatness = 3.0;

  /// Seconds for one lollipop's worth of fat to wear off.
  static const fatWearOffSeconds = 7.0;

  /// A hungry monster gets faster the longer it goes without a lollipop,
  /// up to this much faster, over [hungerSeconds].
  static const maxHungerBoost = 0.4;
  static const hungerSeconds = 20.0;

  /// How fast a monster walks, given how fat and how hungry it is.
  /// Fat monsters waddle slowly; hungry ones hurry. Never as fast as Teddy.
  static double monsterSpeed({
    required int level,
    required double fatness,
    required double secondsHungry,
  }) {
    final hunger = maxHungerBoost * min(1.0, secondsHungry / hungerSeconds);
    final fat = 1 / (1 + 0.35 * fatness.clamp(0, maxFatness));
    return min(teddySpeed * 0.8, monsterSpeedFor(level) * (1 + hunger) * fat);
  }

  /// When caught, Teddy loses a lollipop, but never goes below 0.
  static int sweetsLostWhenCaught(int collected) =>
      min(sweetsLostOnCatch, collected);
}
