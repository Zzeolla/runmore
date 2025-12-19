import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:runmore/model/pace_segment.dart';

class PaceLineChart extends StatelessWidget {
  final List<PaceSegment> segments;

  const PaceLineChart({
    super.key,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    final values = segments.map((s) => s.seconds / s.distance).toList();

    double minVal = values.reduce(math.min);
    double maxVal = values.reduce(math.max);

    double minY = minVal * 0.98;
    double maxY = maxVal * 1.02;

    if (minY == maxY) {
      minY -= 5;
      maxY += 5;
    }

    final range = maxY - minY;
    final interval = range <= 30
        ? 10
        : range <= 90
        ? 20
        : 30;

    final yLabels = <double>[];
    for (double v = minY; v <= maxY; v += interval) {
      yLabels.add(v);
    }

    // 스크롤 폭 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = math.max(screenWidth - 32, segments.length * 32.0);

    final theme = Theme.of(context);

    return SizedBox(
      height: 220, // ✅ 전체 높이는 여기서 딱 한 번만 제한
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // 연두 톤으로 변경
          color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '구간별 페이스',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ 남은 높이를 Row가 전부 쓰도록 Expanded
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ① 왼쪽 Y축 라벨 (고정 영역)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final v in yLabels)
                        Text(
                          _formatPace(v),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // ② 오른쪽 스크롤 가능한 LineChart
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: chartWidth,
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: (values.length - 1).toDouble(),
                            minY: minY,
                            maxY: maxY,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= segments.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${segments[idx].index} km',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < values.length; i++)
                                    FlSpot(i.toDouble(), values[i])
                                ],
                                isCurved: true,
                                color: Colors.indigo,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.indigo.withOpacity(0.15),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpots) =>
                                    Colors.black.withOpacity(0.7),
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final idx = spot.x.toInt();
                                    if (idx < 0 || idx >= segments.length) {
                                      return null;
                                    }
                                    final seg = segments[idx];
                                    final secPerKm = values[idx];
                                    final paceText = _formatPace(secPerKm);
                                    final timeText = _formatTime(seg.seconds);
                                    return LineTooltipItem(
                                      '${seg.index} km\n$paceText  ($timeText)',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }).whereType<LineTooltipItem>().toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPace(double sec) {
    if (sec <= 0) return '--';
    final m = sec ~/ 60;
    final s = (sec % 60).round();
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  static String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
