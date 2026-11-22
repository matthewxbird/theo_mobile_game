import 'package:flutter/widgets.dart';

import '../game/leaderboard.dart';
import '../game/sfx.dart';
import '../game/teddy_colour.dart';
import 'fun_widgets.dart';

/// Title screen: pick your critter and colour, see everyone's stars,
/// press play.
class StartScreen extends StatefulWidget {
  const StartScreen({
    super.key,
    required this.leaderboard,
    required this.onPlay,
  });

  final Leaderboard leaderboard;
  final void Function(Player hero) onPlay;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late Critter _critter = widget.leaderboard.lastCritter;
  late TeddyColour _colour = widget.leaderboard.lastColour;

  void _choose({Critter? critter, TeddyColour? colour}) {
    Sfx.tap.play();
    setState(() {
      _critter = critter ?? _critter;
      _colour = colour ?? _colour;
    });
    widget.leaderboard.choose((_critter, _colour));
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
            const SizedBox(height: 16),
            const PopIn(
              child: Text(
                '🍭 Theo\'s 🍭\nSweet Run',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: brown,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: TeddyPicture(
                  colour: _colour,
                  critter: _critter,
                  size: 160,
                  dancing: true,
                ),
              ),
            ),
            _CritterChooser(
              chosen: _critter,
              onChoose: (critter) => _choose(critter: critter),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<Map<Player, int>>(
              valueListenable: widget.leaderboard.best,
              builder:
                  (context, _, _) => _ColourChooser(
                    critter: _critter,
                    chosen: _colour,
                    leaderboard: widget.leaderboard,
                    onChoose: (colour) => _choose(colour: colour),
                  ),
            ),
            const SizedBox(height: 20),
            PulsingButton(
              onPressed: () => widget.onPlay((_critter, _colour)),
              child: const Text('▶  Play'),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

/// Big buttons to pick bear, dinosaur, chicken or dog.
class _CritterChooser extends StatelessWidget {
  const _CritterChooser({required this.chosen, required this.onChoose});

  final Critter chosen;
  final void Function(Critter critter) onChoose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final critter in Critter.values)
          GestureDetector(
            onTap: () => onChoose(critter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    critter == chosen
                        ? const Color(0xFFFFFFFF)
                        : const Color(0x88FFFFFF),
                border: Border.all(
                  color:
                      critter == chosen
                          ? const Color(0xFFFFC107)
                          : const Color(0x00000000),
                  width: 5,
                ),
              ),
              child: Text(
                critter.emoji,
                style: TextStyle(fontSize: critter == chosen ? 40 : 32),
              ),
            ),
          ),
      ],
    );
  }
}

/// The chosen critter in every colour. Under each: the stars (levels) that
/// one has won. This doubles as the leaderboard, and the leader wears a
/// crown.
class _ColourChooser extends StatelessWidget {
  const _ColourChooser({
    required this.critter,
    required this.chosen,
    required this.leaderboard,
    required this.onChoose,
  });

  final Critter critter;
  final TeddyColour chosen;
  final Leaderboard leaderboard;
  final void Function(TeddyColour colour) onChoose;

  @override
  Widget build(BuildContext context) {
    final leader = leaderboard.leaderFor(critter);
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
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color:
                    colour == chosen
                        ? const Color(0xFFFFFFFF)
                        : const Color(0x88FFFFFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color:
                      colour == chosen
                          ? const Color(0xFFFFC107)
                          : const Color(0x00000000),
                  width: 5,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                    child: Text(
                      colour == leader ? '👑' : '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  TeddyPicture(colour: colour, critter: critter, size: 54),
                  Text(
                    '⭐ ${leaderboard.levelsDone((critter, colour))}',
                    style: const TextStyle(
                      fontSize: 20,
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
