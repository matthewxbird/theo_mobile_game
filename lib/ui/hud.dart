import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../game/layout.dart';

const _brown = Color(0xFF5D3A1A);

/// A rounded white badge with an emoji and some big text.
class _Badge extends StatelessWidget {
  const _Badge({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xDDFFFFFF),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: _brown,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lollipops collected on this level, out of how many are needed.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    super.key,
    required this.score,
    required this.level,
    required this.needed,
  });

  final ValueListenable<int> score;
  final ValueListenable<int> level;
  final int Function(int level) needed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([score, level]),
      builder:
          (context, _) => _Badge(
            emoji: '🍭',
            text: '${score.value}/${needed(level.value)}',
          ),
    );
  }
}

/// Which level we're on.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  final ValueListenable<int> level;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: level,
      builder: (context, value, _) => _Badge(emoji: '⭐', text: '$value'),
    );
  }
}

/// Big round bonus button (honey, beehive). Shows how many are left.
class BonusButton extends StatelessWidget {
  const BonusButton({
    super.key,
    required this.emoji,
    required this.color,
    required this.count,
    required this.onPressed,
  });

  final String emoji;
  final Color color;

  final ValueListenable<int> count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: count,
      builder: (context, value, _) {
        final empty = value == 0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => onPressed(),
          child: Opacity(
            opacity: empty ? 0.4 : 1,
            child: SizedBox(
              width: HudLayout.buttonSize,
              height: HudLayout.buttonSize,
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: empty ? const Color(0xFFBDBDBD) : color,
                      border: Border.all(
                        color: const Color(0xFF8D5524),
                        width: 5,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 52)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8D5524),
                      ),
                      child: Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
