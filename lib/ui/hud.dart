import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Big score badge: a lollipop and a number.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score});

  final ValueListenable<int> score;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: score,
      builder: (context, value, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xDDFFFFFF),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍭', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 10),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5D3A1A),
              ),
            ),
          ],
        ),
      ),
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
