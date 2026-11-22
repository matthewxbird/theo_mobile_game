import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
                  child: IgnorePointer(child: ScoreBadge(score: _game.score)),
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: HoneyButton(
                    honey: _game.honey,
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
