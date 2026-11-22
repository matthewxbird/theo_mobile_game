import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:theo_mobile_game/game/place.dart';
import 'package:theo_mobile_game/game/rules.dart';

void main() {
  group('GameRules', () {
    test('level 1 needs 6 lollipops and each level needs 2 more', () {
      expect(GameRules.sweetsForLevel(1), 6);
      expect(GameRules.sweetsForLevel(2), 8);
      expect(GameRules.sweetsForLevel(3), 10);
    });

    test('lollipops needed stop growing so late levels stay short', () {
      expect(GameRules.sweetsForLevel(6), GameRules.maxSweetsPerLevel);
      expect(GameRules.sweetsForLevel(50), GameRules.maxSweetsPerLevel);
    });

    test('places are random but never the same twice in a row', () {
      final random = Random(42);
      var place = Place.randomAfter(null, random);
      final seen = <Place>{place};
      final orders = <String>{};
      var order = place.name;
      for (var level = 2; level <= 200; level++) {
        final next = Place.randomAfter(place, random);
        expect(next, isNot(place));
        seen.add(next);
        order += ',${next.name}';
        if (level % 4 == 0) {
          orders.add(order);
          order = '';
        }
        place = next;
      }
      // Every place turns up, and they don't just repeat one fixed order.
      expect(seen, Place.values.toSet());
      expect(orders.length, greaterThan(1));
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

    test('fat monsters are slower and hungry monsters are faster', () {
      double speed({double fat = 0, double hungry = 0}) =>
          GameRules.monsterSpeed(level: 1, fatness: fat, secondsHungry: hungry);
      expect(speed(fat: 1), lessThan(speed()));
      expect(speed(fat: 3), lessThan(speed(fat: 1)));
      expect(speed(hungry: 20), greaterThan(speed()));
      expect(speed(hungry: 1000), speed(hungry: GameRules.hungerSeconds));
    });

    test('even the hungriest monster is slower than Teddy', () {
      for (var level = 1; level <= 100; level++) {
        expect(
          GameRules.monsterSpeed(level: level, fatness: 0, secondsHungry: 1000),
          lessThan(GameRules.teddySpeed),
        );
      }
    });

    test('you start with less honey than it takes to make a bee', () {
      expect(GameRules.startingHoney, lessThan(GameRules.honeyForBeehive));
    });

    test('getting caught loses one lollipop, never going below zero', () {
      expect(GameRules.sweetsLostWhenCaught(0), 0);
      expect(GameRules.sweetsLostWhenCaught(1), 1);
      expect(GameRules.sweetsLostWhenCaught(5), 1);
    });
  });
}
