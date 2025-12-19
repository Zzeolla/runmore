import 'package:flutter/material.dart';

class StatsPanel extends StatelessWidget {
  final double km;
  final String pace;
  final String time;
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStop;
  final Future<void> Function() onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const StatsPanel({
    super.key,
    required this.km,
    required this.pace,
    required this.time,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = const Color(0xFF4CAF81); // 런모어 메인 컬러 느낌
    final Color bg = Colors.white;

    String statusText;
    String statusEmoji;

    if (!isRunning) {
      statusText = '준비 완료';
      statusEmoji = '🕒';
    } else if (isPaused) {
      statusText = '일시정지';
      statusEmoji = '⏸️';
    } else {
      statusText = '달리는 중';
      statusEmoji = '🏃‍♂️';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상태 뱃지
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 지표 3개
          Row(
            children: [
              Expanded(
                child: _metric(
                  label: '거리(km)',
                  value: km.toStringAsFixed(2),
                  alignLeft: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metric(
                  label: '페이스(/km)',
                  value: pace,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metric(
                  label: '시간',
                  value: time,
                  alignRight: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRunning)
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      onStart(); // Future<void> 이라 래핑
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '달리기 시작',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (isPaused) ...[
                Expanded(
                  child: FilledButton(
                    onPressed: onResume,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '재개',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onStop,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '종료',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onPause,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '일시정지',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onStop,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '종료',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric({
    required String label,
    required String value,
    bool alignLeft = false,
    bool alignRight = false,
  }) {
    final align = alignLeft
        ? Alignment.centerLeft
        : alignRight
        ? Alignment.centerRight
        : Alignment.center;

    final cross = alignLeft
        ? CrossAxisAlignment.start
        : alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        // ✅ 값만 표시 (고정 폭/짤림 방지)
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: align,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }


  String formatRunTime(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      // h:MM:SS
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // MM:SS
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

}
