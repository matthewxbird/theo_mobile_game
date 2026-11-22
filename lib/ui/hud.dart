import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
      builder: (context, _) => _Badge(
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

/// Big bouncy "Level 2!" in the middle of the screen.
class LevelUpBanner extends StatelessWidget {
  const LevelUpBanner({
    super.key,
    required this.showing,
    required this.level,
  });

  final ValueListenable<bool> showing;
  final ValueListenable<int> level;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showing,
      builder: (context, isShowing, _) {
        if (!isShowing) return const SizedBox.shrink();
        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xEEFFFFFF),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0xFFFFC107), width: 6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐ ⭐ ⭐', style: TextStyle(fontSize: 48)),
                  Text(
                    'Level ${level.value}!',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: _brown,
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

/// Big round honey button. Shows how many honey pots are left.
class HoneyButton extends StatelessWidget {
  const HoneyButton({super.key, required this.honey, required this.onPressed});

  final ValueListenable<int> honey;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: honey,
      builder: (context, value, _) {
        final empty = value == 0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => onPressed(),
          child: Opacity(
            opacity: empty ? 0.4 : 1,
            child: SizedBox(
              width: 112,
              height: 112,
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: empty
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFFFFC107),
                      border: Border.all(
                        color: const Color(0xFF8D5524),
                        width: 5,
                      ),
                    ),
                    child: const Text('🍯', style: TextStyle(fontSize: 52)),
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
