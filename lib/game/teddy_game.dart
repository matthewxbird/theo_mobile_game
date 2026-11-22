import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'components/bee.dart';
import 'components/hat.dart';
import 'components/honey.dart';
import 'components/monster.dart';
import 'components/playground.dart';
import 'components/stolen_lolly.dart';
import 'components/sweet.dart';
import 'components/teddy.dart';
import 'layout.dart';
import 'rules.dart';
import 'sfx.dart';
import 'teddy_colour.dart';

enum GamePhase { menu, ready, playing, levelComplete }

/// Teddy runs around collecting sweets while grumpy monsters chase him.
class TeddyGame extends FlameGame {
  TeddyGame({Random? random}) : _random = random ?? Random();

  /// Space left at the top for the score.
  static const hudHeight = HudLayout.topHeight;
  static const edgeMargin = 40.0;
  static const _pickupDistance = 45.0;
  static const _catchDistance = 48.0;
  static const _honeyDistance = 40.0;
  static const _beesPerMonster = 3;

  static const _monsterColors = [
    Color(0xFF9B6BD6),
    Color(0xFF4A90E2),
    Color(0xFFE36B9A),
    Color(0xFFF08A3C),
  ];

  final Random _random;

  /// Lollipops collected on this level.
  final score = ValueNotifier<int>(0);
  final level = ValueNotifier<int>(1);
  final honey = ValueNotifier<int>(GameRules.startingHoney);

  /// Beehives to use. You get one each time you finish a level, and one
  /// every time 4 honey pots magically turn into a bee.
  final beehives = ValueNotifier<int>(0);

  /// Goes up by one each time honey turns into a bee, so the HUD can play
  /// the animation.
  final honeyTurnedIntoBee = ValueNotifier<int>(0);

  /// Bees still flying to the bee button. Each is added when it lands.
  final List<double> _beesOnTheWay = [];

  /// Which screen we're on. Monsters only move while [GamePhase.playing].
  final phase = ValueNotifier<GamePhase>(GamePhase.menu);

  late final Teddy teddy;
  double _monsterTimer = GameRules.firstMonsterDelay;
  double _honeyJarTimer = GameRules.honeyJarInterval;
  double _hatTimer = GameRules.hatInterval;

  bool get isPlaying => phase.value == GamePhase.playing;
  TeddyColour get colour => teddy.colour;

  /// Start a new game from level 1 with the chosen teddy.
  void startNewGame(TeddyColour colour) {
    if (!isLoaded) return;
    teddy.colour = colour;
    level.value = 1;
    score.value = 0;
    honey.value = GameRules.startingHoney;
    beehives.value = 0;
    _beesOnTheWay.clear();
    _clearBoard();
    // A new game starts with no hat anywhere.
    teddy.hasHat = false;
    for (final hat in children.whereType<HatPickup>().toList()) {
      hat.removeFromParent();
    }
    _hatTimer = GameRules.hatInterval;
    phase.value = GamePhase.ready;
  }

  /// From the level complete screen: get ready for the next level.
  void nextLevel() {
    _clearBoard();
    phase.value = GamePhase.ready;
  }

  /// The "3, 2, 1, Go!" countdown has finished.
  void go() {
    _monsterTimer = GameRules.firstMonsterDelay;
    phase.value = GamePhase.playing;
  }

  void backToMenu() {
    _clearBoard();
    phase.value = GamePhase.menu;
  }

  void _clearBoard() {
    for (final c
        in children
            .where((c) => c is Monster || c is Bee || c is StolenLolly)
            .toList()) {
      c.removeFromParent();
    }
    for (final c in children.whereType<HoneyPuddle>().toList()) {
      c.removeFromParent();
    }
    // A hat still in the air when the level ends comes back to Teddy.
    for (final hat in children.whereType<ThrownHat>().toList()) {
      hat.removeFromParent();
      teddy.hasHat = true;
    }
    teddy.resetTo(size / 2);
  }

  /// The chasing monster closest to [point], if there is one.
  Monster? nearestMonsterTo(Vector2 point) {
    Monster? nearest;
    var best = double.infinity;
    for (final monster in children.whereType<Monster>()) {
      if (!monster.isChasing) continue;
      final distance = monster.position.distanceTo(point);
      if (distance < best) {
        best = distance;
        nearest = monster;
      }
    }
    return nearest;
  }

  void _onTap(Vector2 point) {
    if (!isPlaying) return;
    final tappedTeddy =
        point.distanceTo(teddy.position) < GameRules.hatTapDistance;
    if (teddy.hasHat && tappedTeddy) {
      _throwHat();
      return;
    }
    teddy.moveTo(clampToField(point));
  }

  /// Teddy throws his hat at the nearest monster.
  void _throwHat() {
    final target = nearestMonsterTo(teddy.position);
    // Nobody to throw at: keep the hat on.
    if (target == null) return;
    teddy.throwHat();
    add(ThrownHat(position: teddy.position - Vector2(0, 30), target: target));
    Sfx.whoosh.play();
    HapticFeedback.mediumImpact();
  }

  int get sweetsNeeded => GameRules.sweetsForLevel(level.value);

  @override
  Color backgroundColor() => const Color(0xFFB7E4A0);

  Rect get field => Rect.fromLTRB(
    edgeMargin,
    hudHeight,
    max(edgeMargin, size.x - edgeMargin),
    max(hudHeight, size.y - edgeMargin),
  );

  Vector2 clampToField(Vector2 point) => Vector2(
    point.x.clamp(field.left, field.right),
    point.y.clamp(field.top, field.bottom),
  );

  @override
  Future<void> onLoad() async {
    await Sfx.load();
    teddy = Teddy(position: size / 2);
    add(Playground(onTap: _onTap));
    add(teddy);
    for (var i = 0; i < GameRules.sweetsOnScreen; i++) {
      _spawnSweet();
    }
  }

  /// Called by the honey button.
  void dropHoney() {
    if (!isPlaying || honey.value == 0) return;
    honey.value--;
    add(HoneyPuddle(position: teddy.position.clone()));
    Sfx.honey.play();
    HapticFeedback.lightImpact();
  }

  /// Called by the beehive button: send bees to sting every monster.
  void useBeehive() {
    if (!isPlaying || beehives.value == 0) return;
    final targets =
        children.whereType<Monster>().where((m) => m.isChasing).toList();
    // Don't waste a beehive when there's nobody to sting.
    if (targets.isEmpty) return;
    beehives.value--;
    for (final monster in targets) {
      for (var i = 0; i < _beesPerMonster; i++) {
        add(
          Bee(
            position: teddy.position.clone(),
            target: monster,
            delay: i * 0.12,
          ),
        );
      }
    }
    Sfx.buzz.play();
    HapticFeedback.mediumImpact();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _landBees(dt);
    if (!isPlaying) return;
    _collectPickups();
    if (!isPlaying) return;
    _updateMonsters();
    _spawnMonsters(dt);
    _spawnHoneyJars(dt);
    _spawnHat(dt);
  }

  /// Only one hat at a time: none while Teddy wears one, one lies on the
  /// floor, or one is flying.
  void _spawnHat(double dt) {
    final hatAround =
        teddy.hasHat ||
        children.any((c) => c is ThrownHat || (c is HatPickup && !c.collected));
    if (hatAround) return;
    _hatTimer -= dt;
    if (_hatTimer > 0) return;
    _hatTimer = GameRules.hatInterval;
    add(HatPickup(position: _randomFieldPoint()));
  }

  void _levelComplete() {
    level.value++;
    score.value = 0;
    beehives.value += GameRules.beehivesPerLevelUp;
    for (final monster in children.whereType<Monster>()) {
      monster.flashAndFade();
    }
    phase.value = GamePhase.levelComplete;
    Sfx.levelUp.play();
    HapticFeedback.heavyImpact();
  }

  void _collectPickups() {
    for (final sweet in children.whereType<Sweet>().toList()) {
      if (sweet.collected || !_near(sweet, _pickupDistance)) continue;
      sweet.collect();
      score.value++;
      teddy.celebrate();
      Sfx.sweet.play();
      HapticFeedback.selectionClick();
      if (score.value >= sweetsNeeded) {
        _levelComplete();
        return;
      }
    }
    final sweetsLeft =
        children.whereType<Sweet>().where((s) => !s.collected).length;
    for (var i = sweetsLeft; i < GameRules.sweetsOnScreen; i++) {
      _spawnSweet();
    }

    for (final hat in children.whereType<HatPickup>().toList()) {
      if (hat.collected || teddy.hasHat || !_near(hat, _pickupDistance)) {
        continue;
      }
      hat.collect();
      teddy.hasHat = true;
      Sfx.tada.play();
      HapticFeedback.selectionClick();
    }

    for (final jar in children.whereType<HoneyJar>().toList()) {
      if (jar.collected || !_near(jar, _pickupDistance)) continue;
      jar.collect();
      teddy.celebrate();
      honey.value++;
      Sfx.jar.play();
      HapticFeedback.selectionClick();
      if (honey.value >= GameRules.honeyForBeehive) _turnHoneyIntoBee();
    }
  }

  /// Magic! 4 honey pots fly together and become a bee.
  void _turnHoneyIntoBee() {
    honey.value -= GameRules.honeyForBeehive;
    _beesOnTheWay.add(GameRules.honeyToBeeSeconds);
    honeyTurnedIntoBee.value++;
  }

  void _landBees(double dt) {
    for (var i = _beesOnTheWay.length - 1; i >= 0; i--) {
      _beesOnTheWay[i] -= dt;
      if (_beesOnTheWay[i] <= 0) {
        _beesOnTheWay.removeAt(i);
        beehives.value++;
        HapticFeedback.lightImpact();
      }
    }
  }

  void _updateMonsters() {
    final puddles = children.whereType<HoneyPuddle>().toList();
    for (final monster in children.whereType<Monster>().toList()) {
      if (!monster.isChasing) continue;
      monster.speed = GameRules.monsterSpeed(
        level: level.value,
        fatness: monster.fatness,
        secondsHungry: monster.secondsHungry,
      );

      final puddle = puddles
          .where((p) => !p.used)
          .firstWhereOrNull(
            (p) => p.position.distanceTo(monster.position) < _honeyDistance,
          );
      if (puddle != null) {
        puddle.use();
        monster.slip();
        Sfx.slip.play();
        continue;
      }

      if (monster.canCatch && !teddy.isSafe && _near(monster, _catchDistance)) {
        _caught(monster);
      }
    }
  }

  void _caught(Monster monster) {
    final stolen = GameRules.sweetsLostWhenCaught(score.value);
    score.value -= stolen;
    // The monster snatches the lollipop and eats it. It's gone for good.
    for (var i = 0; i < stolen; i++) {
      add(
        StolenLolly(
          position: teddy.position.clone(),
          monster: monster,
          color: Sweet.colors[_random.nextInt(Sweet.colors.length)],
        ),
      );
    }
    teddy.makeSafe();
    monster.bounceAwayFrom(teddy.position);
    Sfx.caught.play();
    HapticFeedback.mediumImpact();
  }

  void _spawnMonsters(double dt) {
    final chasing = children.whereType<Monster>().where((m) => m.isChasing);
    if (chasing.length >= GameRules.monstersFor(level.value)) {
      _monsterTimer = max(_monsterTimer, GameRules.monsterRespawnDelay);
      return;
    }
    _monsterTimer -= dt;
    if (_monsterTimer > 0) return;
    _monsterTimer = GameRules.monsterRespawnDelay;
    add(
      Monster(
        position: _edgePointAwayFromTeddy(),
        color: _monsterColors[_random.nextInt(_monsterColors.length)],
      ),
    );
  }

  void _spawnHoneyJars(double dt) {
    final hasJar = children.whereType<HoneyJar>().any((j) => !j.collected);
    if (hasJar) return;
    _honeyJarTimer -= dt;
    if (_honeyJarTimer > 0) return;
    _honeyJarTimer = GameRules.honeyJarInterval;
    add(HoneyJar(position: _randomFieldPoint()));
  }

  void _spawnSweet() {
    add(
      Sweet(
        position: _randomFieldPoint(),
        color: Sweet.colors[_random.nextInt(Sweet.colors.length)],
      ),
    );
  }

  bool _near(PositionComponent other, double distance) =>
      other.position.distanceTo(teddy.position) < distance;

  Vector2 _randomFieldPoint() {
    // Keep pickups out of the strip with the big bonus buttons.
    final bottom = max(field.top, size.y - HudLayout.bottomStrip);
    var point = Vector2.zero();
    for (var i = 0; i < 20; i++) {
      point = Vector2(
        field.left + _random.nextDouble() * field.width,
        field.top + _random.nextDouble() * (bottom - field.top),
      );
      if (point.distanceTo(teddy.position) > 120) break;
    }
    return point;
  }

  Vector2 _edgePointAwayFromTeddy() {
    var point = Vector2.zero();
    for (var i = 0; i < 20; i++) {
      final t = _random.nextDouble();
      point = switch (_random.nextInt(4)) {
        0 => Vector2(field.left + t * field.width, field.top),
        1 => Vector2(field.left + t * field.width, field.bottom),
        2 => Vector2(field.left, field.top + t * field.height),
        _ => Vector2(field.right, field.top + t * field.height),
      };
      if (point.distanceTo(teddy.position) >
          GameRules.minMonsterSpawnDistance) {
        break;
      }
    }
    return point;
  }
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
