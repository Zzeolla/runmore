import 'package:flutter/material.dart';
import 'package:runmore/db/app_database.dart';

import 'stat_chip.dart';

class RunHistoryCard extends StatelessWidget {
  final Run run;
  final VoidCallback? onTap;

  const RunHistoryCard({
    super.key,
    required this.run,
    this.onTap,
  });

  String _formatDate(DateTime dt) {
    // TODO: intl 패키지 쓰면 더 깔끔하지만 우선 간단하게
    final weekdayKo = ['월', '화', '수', '목', '금', '토', '일'][dt.weekday - 1];
    return "${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ($weekdayKo)";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _formatDistance(double meters) {
    final km = meters / 1000.0;
    return km.toStringAsFixed(2);
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    } else {
      return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
  }

  String _formatPace(double meters, int seconds) {
    if (meters <= 0 || seconds <= 0) return '--';
    final km = meters / 1000.0;
    final paceSec = (seconds / km).round();
    final m = paceSec ~/ 60;
    final s = paceSec % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 아래 필드명은 실제 Run dataClass에 맞게 수정
    final startedAt = run.startedAt;
    final distanceMeters = run.distanceMeters;
    final elapsedSeconds = run.elapsedSeconds;

    final dateStr = _formatDate(startedAt);
    final timeStr = _formatTime(startedAt);
    final distanceStr = _formatDistance(distanceMeters);
    final durationStr = _formatDuration(elapsedSeconds);
    final paceStr = _formatPace(distanceMeters, elapsedSeconds);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      distanceStr,
                      style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'km',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatChip(
                  icon: Icons.timer_outlined,
                  label: '시간',
                  value: durationStr,
                ),
                const SizedBox(width: 8),
                StatChip(
                  icon: Icons.directions_run,
                  label: '평균 페이스',
                  value: paceStr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
