import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'game/layout.dart';
import 'game/leaderboard.dart';
import 'game/rules.dart';
import 'game/teddy_colour.dart';
import 'game/teddy_game.dart';
import 'ui/get_ready.dart';
import 'ui/hud.dart';
import 'ui/level_complete.dart';
import 'ui/start_screen.dart';

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
  final _leaderboard = Leaderboard();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _leaderboard.load().then((_) {
      if (mounted) setState(() => _loaded = true);
    });
    _game.phase.addListener(_onPhaseChanged);
  }

  @override
  void dispose() {
    _game.phase.removeListener(_onPhaseChanged);
    super.dispose();
  }

  void _onPhaseChanged() {
    if (_game.phase.value == GamePhase.levelComplete) {
      _leaderboard.record(_game.colour, _game.level.value - 1);
    }
  }

  void _play(TeddyColour colour) {
    _leaderboard.chooseColour(colour);
    _game.startNewGame(colour);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          GameWidget(game: _game),
          ValueListenableBuilder<GamePhase>(
            valueListenable: _game.phase,
            builder:
                (context, phase, _) => switch (phase) {
                  GamePhase.menu =>
                    _loaded
                        ? StartScreen(leaderboard: _leaderboard, onPlay: _play)
                        : const SizedBox.expand(),
                  GamePhase.ready => Stack(
                    children: [
                      _hud(),
                      GetReady(level: _game.level.value, onDone: _game.go),
                    ],
                  ),
                  GamePhase.playing => _hud(),
                  GamePhase.levelComplete => LevelCompleteScreen(
                    colour: _game.colour,
                    nextLevel: _game.level.value,
                    onNext: _game.nextLevel,
                    onHome: _game.backToMenu,
                  ),
                },
          ),
        ],
      ),
    );
  }

  Widget _hud() {
    return SafeArea(
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
          Positioned(
            left: HudLayout.buttonMargin,
            bottom: HudLayout.buttonMargin,
            child: BonusButton(
              emoji: '🐝',
              color: const Color(0xFFFFB74D),
              count: _game.beehives,
              onPressed: _game.useBeehive,
            ),
          ),
          Positioned(
            right: HudLayout.buttonMargin,
            bottom: HudLayout.buttonMargin,
            child: BonusButton(
              emoji: '🍯',
              color: const Color(0xFFFFC107),
              count: _game.honey,
              onPressed: _game.dropHoney,
            ),
          ),
        ],
      ),
    );
  }
}
