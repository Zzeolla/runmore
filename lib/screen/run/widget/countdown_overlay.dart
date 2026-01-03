import 'package:flutter/material.dart';

class CountdownOverlay extends StatelessWidget {
  final int seconds; // 5,4,3,2,1,0
  const CountdownOverlay({
    super.key,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    final isStart = seconds <= 0;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false, // 카운트다운 중 터치 차단
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            color: Colors.black.withValues(alpha: 0.75),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      isStart ? 'START' : '$seconds',
                      key: ValueKey(seconds),
                      style: TextStyle(
                        fontSize: isStart ? 80 : 140,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isStart ? '달리기 시작!' : '곧 시작합니다',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
