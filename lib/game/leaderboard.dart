import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'teddy_colour.dart';

/// Best level finished by each teddy colour, saved on the phone.
class Leaderboard {
  static const _bestKey = 'best_level_';
  static const _lastColourKey = 'last_colour';

  final best = ValueNotifier<Map<TeddyColour, int>>({});
  TeddyColour lastColour = TeddyColour.brown;

  /// The teddy with the most levels done, if anyone has finished one.
  TeddyColour? get leader {
    TeddyColour? top;
    var topLevels = 0;
    for (final entry in best.value.entries) {
      if (entry.value > topLevels) {
        top = entry.key;
        topLevels = entry.value;
      }
    }
    return top;
  }

  int levelsDone(TeddyColour colour) => best.value[colour] ?? 0;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      best.value = {
        for (final colour in TeddyColour.values)
          colour: prefs.getInt('$_bestKey${colour.name}') ?? 0,
      };
      final last = prefs.getString(_lastColourKey);
      lastColour = TeddyColour.values.firstWhere(
        (c) => c.name == last,
        orElse: () => TeddyColour.brown,
      );
    } catch (error) {
      debugPrint('Could not load leaderboard: $error');
    }
  }

  Future<void> chooseColour(TeddyColour colour) async {
    lastColour = colour;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastColourKey, colour.name);
    } catch (error) {
      debugPrint('Could not save colour: $error');
    }
  }

  /// Remember [levels] for [colour] if it beats their best.
  Future<void> record(TeddyColour colour, int levels) async {
    if (levels <= levelsDone(colour)) return;
    best.value = {...best.value, colour: levels};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_bestKey${colour.name}', levels);
    } catch (error) {
      debugPrint('Could not save leaderboard: $error');
    }
  }
}
