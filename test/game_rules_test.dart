import 'package:flutter_test/flutter_test.dart';
import 'package:theo_mobile_game/game/rules.dart';

void main() {
  group('GameRules', () {
    test('starts with one monster and never more than the max', () {
      expect(GameRules.monstersFor(0), 1);
      expect(GameRules.monstersFor(10), 2);
      expect(GameRules.monstersFor(1000), GameRules.maxMonsters);
    });

    test('monsters are always slower than Teddy', () {
      for (var score = 0; score <= 1000; score += 7) {
        expect(
          GameRules.monsterSpeedFor(score),
          lessThan(GameRules.teddySpeed),
        );
      }
    });

    test('getting caught never takes the score below zero', () {
      expect(GameRules.sweetsDroppedOnCatch(0), 0);
      expect(GameRules.sweetsDroppedOnCatch(2), 2);
      expect(
        GameRules.sweetsDroppedOnCatch(50),
        GameRules.maxSweetsDroppedOnCatch,
      );
    });
  });
}
