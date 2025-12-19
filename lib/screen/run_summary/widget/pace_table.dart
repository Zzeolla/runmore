import 'package:flutter/material.dart';
import 'package:runmore/model/pace_segment.dart';

class PaceTable extends StatelessWidget {
  final List<PaceSegment> segments;
  final PaceSegment? lastPartial; // 👈 추가

  const PaceTable({
    super.key,
    required this.segments,
    this.lastPartial,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Expanded(child: Center(child: Text('구간', style: TextStyle(fontWeight: FontWeight.w600)))),
              Expanded(child: Center(child: Text('페이스', style: TextStyle(fontWeight: FontWeight.w600)))),
              Expanded(child: Center(child: Text('시간', style: TextStyle(fontWeight: FontWeight.w600)))),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          for (final s in segments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Center(child: Text('${s.index} km'))),
                  Expanded(child: Center(child: Text(_formatPace(s)))),
                  Expanded(child: Center(child: Text(_formatTime(s.cumulativeSeconds)))),
                ],
              ),
            ),

          if (lastPartial != null) ...[
            const SizedBox(height: 4),
            const Divider(height: 1),
            const SizedBox(height: 4),
            Text(
              '마지막 구간: +${_formatDistanceM(lastPartial!.distance)} (${_formatTime(lastPartial!.seconds)})',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatPace(PaceSegment s) {
    if (s.seconds == 0 || s.distance <= 0) return '--';
    final speed = (s.distance * 1000) / s.seconds;
    final paceSec = 1000 / speed; // sec per km
    final m = paceSec ~/ 60;
    final sec = (paceSec % 60).toInt();
    return "$m'${sec.toString().padLeft(2, '0')}\"";
  }

  static String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDistanceM(double km) {
    final meters = (km * 1000).round(); // 정수 미터
    return '$meters m';
  }
}
