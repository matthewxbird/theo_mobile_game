import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'teddy_colour.dart';

/// One player's look: which critter, in which colour.
typedef Player = (Critter, TeddyColour);

/// Best level finished by each critter and colour, saved on the phone.
class Leaderboard {
  static const _bestKey = 'best_level_';
  static const _lastColourKey = 'last_colour';
  static const _lastCritterKey = 'last_critter';

  final best = ValueNotifier<Map<Player, int>>({});
  TeddyColour lastColour = TeddyColour.brown;
  Critter lastCritter = Critter.bear;

  /// Bears keep the original keys (best_level_pink), so scores from before
  /// there were other critters still count.
  static String _key(Player hero) {
    final (critter, colour) = hero;
    return critter == Critter.bear
        ? '$_bestKey${colour.name}'
        : '$_bestKey${critter.name}_${colour.name}';
  }

  /// The [critter] with the most levels done, if anyone has finished one.
  TeddyColour? leaderFor(Critter critter) {
    TeddyColour? top;
    var topLevels = 0;
    for (final colour in TeddyColour.values) {
      final levels = levelsDone((critter, colour));
      if (levels > topLevels) {
        top = colour;
        topLevels = levels;
      }
    }
    return top;
  }

  int levelsDone(Player hero) => best.value[hero] ?? 0;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      best.value = {
        for (final critter in Critter.values)
          for (final colour in TeddyColour.values)
            (critter, colour): prefs.getInt(_key((critter, colour))) ?? 0,
      };
      final lastColourName = prefs.getString(_lastColourKey);
      lastColour = TeddyColour.values.firstWhere(
        (c) => c.name == lastColourName,
        orElse: () => TeddyColour.brown,
      );
      final lastCritterName = prefs.getString(_lastCritterKey);
      lastCritter = Critter.values.firstWhere(
        (c) => c.name == lastCritterName,
        orElse: () => Critter.bear,
      );
    } catch (error) {
      debugPrint('Could not load leaderboard: $error');
    }
  }

  /// Remember who played last, so the start screen picks them again.
  Future<void> choose(Player hero) async {
    lastCritter = hero.$1;
    lastColour = hero.$2;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastCritterKey, lastCritter.name);
      await prefs.setString(_lastColourKey, lastColour.name);
    } catch (error) {
      debugPrint('Could not save choice: $error');
    }
  }

  /// Remember [levels] for [hero] if it beats their best.
  Future<void> record(Player hero, int levels) async {
    if (levels <= levelsDone(hero)) return;
    best.value = {...best.value, hero: levels};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key(hero), levels);
    } catch (error) {
      debugPrint('Could not save leaderboard: $error');
    }
  }
}
