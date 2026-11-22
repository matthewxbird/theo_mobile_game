import 'package:flutter_test/flutter_test.dart';
import 'package:theo_mobile_game/game/rules.dart';

void main() {
  group('GameRules', () {
    test('level 1 needs 6 lollipops and each level needs 2 more', () {
      expect(GameRules.sweetsForLevel(1), 6);
      expect(GameRules.sweetsForLevel(2), 8);
      expect(GameRules.sweetsForLevel(3), 10);
    });

    test('one more monster each level, never more than the max', () {
      expect(GameRules.monstersFor(1), 1);
      expect(GameRules.monstersFor(2), 2);
      expect(GameRules.monstersFor(100), GameRules.maxMonsters);
    });

    test('monsters are always slower than Teddy', () {
      for (var level = 1; level <= 100; level++) {
        expect(
          GameRules.monsterSpeedFor(level),
          lessThan(GameRules.teddySpeed),
        );
      }
    });

    test('getting caught loses one lollipop, never going below zero', () {
      expect(GameRules.sweetsLostWhenCaught(0), 0);
      expect(GameRules.sweetsLostWhenCaught(1), 1);
      expect(GameRules.sweetsLostWhenCaught(5), 1);
    });
  });
}
