import 'package:flutter/widgets.dart';

import '../game/sfx.dart';
import '../game/teddy_colour.dart';
import 'fun_widgets.dart';

/// A party! Confetti, a dancing teddy, stars and the beehive prize,
/// then a big button to start the next level.
class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({
    super.key,
    required this.colour,
    required this.nextLevel,
    required this.onNext,
    required this.onHome,
  });

  final TeddyColour colour;
  final int nextLevel;
  final VoidCallback onNext;
  final VoidCallback onHome;

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen> {
  @override
  void initState() {
    super.initState();
    // A "bling" as each star pops in.
    for (var i = 0; i < 3; i++) {
      Future.delayed(_starDelay(i), () {
        if (mounted) Sfx.sweet.play();
      });
    }
  }

  static Duration _starDelay(int i) => Duration(milliseconds: 500 + i * 350);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF59D), Color(0xFFF8BBD0)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: Confetti()),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Sfx.tap.play();
                      widget.onHome();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xCCFFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🏠', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                ),
                const PopIn(
                  child: Text(
                    'Yay! 🎉',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: brown,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      PopIn(
                        delay: _starDelay(i),
                        child: Text(
                          '⭐',
                          style: TextStyle(fontSize: i == 1 ? 84 : 64),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: TeddyPicture(
                      colour: widget.colour,
                      size: 200,
                      dancing: true,
                    ),
                  ),
                ),
                PopIn(
                  delay: const Duration(milliseconds: 1600),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xDDFFFFFF),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      '+1 🐝',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                PopIn(
                  delay: const Duration(milliseconds: 2000),
                  child: PulsingButton(
                    color: const Color(0xFFFF7043),
                    onPressed: widget.onNext,
                    child: Text('🚀  Level ${widget.nextLevel}'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
