import 'dart:async';

import 'package:flutter/widgets.dart';

import '../game/place.dart';
import '../game/sfx.dart';
import 'fun_widgets.dart';

/// "Level 2 ... 3, 2, 1, Go!" before every level.
class GetReady extends StatefulWidget {
  const GetReady({
    super.key,
    required this.level,
    required this.place,
    required this.onDone,
  });

  /// Where this level is, shown as an emoji.
  final Place place;

  final int level;
  final VoidCallback onDone;

  @override
  State<GetReady> createState() => _GetReadyState();
}

class _GetReadyState extends State<GetReady> {
  static const _steps = ['3', '2', '1', 'Go!'];
  static const _stepTime = Duration(milliseconds: 750);

  int _step = -1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Show the level for a moment before counting.
    _timer = Timer(const Duration(milliseconds: 900), _next);
  }

  void _next() {
    if (!mounted) return;
    if (_step == _steps.length - 1) {
      widget.onDone();
      return;
    }
    setState(() => _step++);
    (_step == _steps.length - 1 ? Sfx.go : Sfx.tick).play();
    _timer = Timer(_stepTime, _next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x66000000),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopIn(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xEEFFFFFF),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                '${widget.place.emoji} Level ${widget.level}',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: brown,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child:
                _step < 0
                    ? null
                    : PopIn(
                      key: ValueKey(_step),
                      child: Text(
                        _steps[_step],
                        style: TextStyle(
                          fontSize: _step == _steps.length - 1 ? 110 : 150,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFFFFF),
                          shadows: const [
                            Shadow(
                              color: Color(0xFFFF9800),
                              offset: Offset(5, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
