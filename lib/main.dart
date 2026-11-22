import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'game/rules.dart';
import 'game/teddy_game.dart';
import 'ui/hud.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Full screen, so little fingers don't hit the system buttons.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const TeddyApp());
}

class TeddyApp extends StatefulWidget {
  const TeddyApp({super.key});

  @override
  State<TeddyApp> createState() => _TeddyAppState();
}

class _TeddyAppState extends State<TeddyApp> {
  final _game = TeddyGame();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          GameWidget(game: _game),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: IgnorePointer(
                    child: ScoreBadge(
                      score: _game.score,
                      level: _game.level,
                      needed: GameRules.sweetsForLevel,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IgnorePointer(child: LevelBadge(level: _game.level)),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: LevelUpBanner(
                      showing: _game.celebrating,
                      level: _game.level,
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: BonusButton(
                    emoji: '🐝',
                    color: const Color(0xFFFFB74D),
                    count: _game.beehives,
                    onPressed: _game.useBeehive,
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: BonusButton(
                    emoji: '🍯',
                    color: const Color(0xFFFFC107),
                    count: _game.honey,
                    onPressed: _game.dropHoney,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
