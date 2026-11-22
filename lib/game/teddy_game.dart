import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'components/honey.dart';
import 'components/monster.dart';
import 'components/playground.dart';
import 'components/sweet.dart';
import 'components/teddy.dart';
import 'rules.dart';
import 'sfx.dart';

/// Teddy runs around collecting sweets while grumpy monsters chase him.
class TeddyGame extends FlameGame {
  TeddyGame({Random? random}) : _random = random ?? Random();

  /// Space left at the top for the score.
  static const hudHeight = 110.0;
  static const edgeMargin = 40.0;
  static const _pickupDistance = 45.0;
  static const _catchDistance = 48.0;
  static const _honeyDistance = 40.0;

  static const _monsterColors = [
    Color(0xFF9B6BD6),
    Color(0xFF4A90E2),
    Color(0xFFE36B9A),
    Color(0xFFF08A3C),
  ];

  final Random _random;
  final score = ValueNotifier<int>(0);
  final honey = ValueNotifier<int>(GameRules.startingHoney);

  late final Teddy teddy;
  double _monsterTimer = GameRules.firstMonsterDelay;
  double _honeyJarTimer = GameRules.honeyJarInterval;

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
    add(Playground(onTap: (point) => teddy.moveTo(clampToField(point))));
    add(teddy);
    for (var i = 0; i < GameRules.sweetsOnScreen; i++) {
      _spawnSweet();
    }
  }

  /// Called by the honey button.
  void dropHoney() {
    if (honey.value == 0) return;
    honey.value--;
    add(HoneyPuddle(position: teddy.position.clone()));
    Sfx.honey.play();
    HapticFeedback.lightImpact();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _collectPickups();
    _updateMonsters();
    _spawnMonsters(dt);
    _spawnHoneyJars(dt);
  }

  void _collectPickups() {
    for (final sweet in children.whereType<Sweet>().toList()) {
      if (sweet.collected || !_near(sweet, _pickupDistance)) continue;
      sweet.collect();
      score.value++;
      Sfx.sweet.play();
      HapticFeedback.selectionClick();
    }
    final sweetsLeft =
        children.whereType<Sweet>().where((s) => !s.collected).length;
    for (var i = sweetsLeft; i < GameRules.sweetsOnScreen; i++) {
      _spawnSweet();
    }

    for (final jar in children.whereType<HoneyJar>().toList()) {
      if (jar.collected || !_near(jar, _pickupDistance)) continue;
      jar.collect();
      honey.value = min(GameRules.maxHoney, honey.value + 1);
      Sfx.jar.play();
      HapticFeedback.selectionClick();
    }
  }

  void _updateMonsters() {
    final speed = GameRules.monsterSpeedFor(score.value);
    final puddles = children.whereType<HoneyPuddle>().toList();
    for (final monster in children.whereType<Monster>().toList()) {
      if (!monster.isChasing) continue;
      monster.speed = speed;

      final puddle = puddles.where((p) => !p.used).firstWhereOrNull(
            (p) => p.position.distanceTo(monster.position) < _honeyDistance,
          );
      if (puddle != null) {
        puddle.use();
        monster.slip();
        Sfx.slip.play();
        continue;
      }

      if (!teddy.isSafe && _near(monster, _catchDistance)) {
        _caught(monster);
      }
    }
  }

  void _caught(Monster monster) {
    final dropped = GameRules.sweetsDroppedOnCatch(score.value);
    score.value -= dropped;
    for (var i = 0; i < dropped; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 90 + _random.nextDouble() * 40;
      _spawnSweet(
        at: teddy.position + Vector2(cos(angle), sin(angle)) * distance,
      );
    }
    teddy.makeSafe();
    monster.bounceAwayFrom(teddy.position);
    Sfx.caught.play();
    HapticFeedback.mediumImpact();
  }

  void _spawnMonsters(double dt) {
    final chasing = children.whereType<Monster>().where((m) => m.isChasing);
    if (chasing.length >= GameRules.monstersFor(score.value)) {
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
    if (hasJar || honey.value >= GameRules.maxHoney) return;
    _honeyJarTimer -= dt;
    if (_honeyJarTimer > 0) return;
    _honeyJarTimer = GameRules.honeyJarInterval;
    add(HoneyJar(position: _randomFieldPoint()));
  }

  void _spawnSweet({Vector2? at}) {
    add(
      Sweet(
        position: at != null ? clampToField(at) : _randomFieldPoint(),
        color: Sweet.colors[_random.nextInt(Sweet.colors.length)],
      ),
    );
  }

  bool _near(PositionComponent other, double distance) =>
      other.position.distanceTo(teddy.position) < distance;

  Vector2 _randomFieldPoint() {
    var point = Vector2.zero();
    for (var i = 0; i < 20; i++) {
      point = Vector2(
        field.left + _random.nextDouble() * field.width,
        field.top + _random.nextDouble() * field.height,
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
