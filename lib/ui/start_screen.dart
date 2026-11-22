import 'package:flutter/widgets.dart';

import '../game/leaderboard.dart';
import '../game/sfx.dart';
import '../game/teddy_colour.dart';
import 'fun_widgets.dart';

/// Title screen: pick your teddy, see everyone's stars, press play.
class StartScreen extends StatefulWidget {
  const StartScreen({
    super.key,
    required this.leaderboard,
    required this.onPlay,
  });

  final Leaderboard leaderboard;
  final void Function(TeddyColour colour) onPlay;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late TeddyColour _chosen = widget.leaderboard.lastColour;

  void _choose(TeddyColour colour) {
    Sfx.tap.play();
    setState(() => _chosen = colour);
    widget.leaderboard.chooseColour(colour);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFFB7E4A0)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const PopIn(
              child: Text(
                '🍭 Teddy\'s 🍭\nSweet Run',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: brown,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: TeddyPicture(colour: _chosen, size: 190, dancing: true),
              ),
            ),
            ValueListenableBuilder<Map<TeddyColour, int>>(
              valueListenable: widget.leaderboard.best,
              builder: (context, _, _) => _TeddyChooser(
                chosen: _chosen,
                leaderboard: widget.leaderboard,
                onChoose: _choose,
              ),
            ),
            const SizedBox(height: 28),
            PulsingButton(
              onPressed: () => widget.onPlay(_chosen),
              child: const Text('▶  Play'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// A row of teddies. Under each: the stars (levels) that teddy has won.
/// This doubles as the leaderboard, and the leader wears a crown.
class _TeddyChooser extends StatelessWidget {
  const _TeddyChooser({
    required this.chosen,
    required this.leaderboard,
    required this.onChoose,
  });

  final TeddyColour chosen;
  final Leaderboard leaderboard;
  final void Function(TeddyColour colour) onChoose;

  @override
  Widget build(BuildContext context) {
    final leader = leaderboard.leader;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final colour in TeddyColour.values)
          GestureDetector(
            onTap: () => onChoose(colour),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 104,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: colour == chosen
                    ? const Color(0xFFFFFFFF)
                    : const Color(0x88FFFFFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colour == chosen
                      ? const Color(0xFFFFC107)
                      : const Color(0x00000000),
                  width: 5,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 22,
                    child: Text(
                      colour == leader ? '👑' : '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  TeddyPicture(colour: colour, size: 60),
                  Text(
                    '⭐ ${leaderboard.levelsDone(colour)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: brown,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
