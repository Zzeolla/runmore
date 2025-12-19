import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/model/pace_segment.dart';
import 'package:runmore/model/run_stats.dart';
import 'package:runmore/screen/run_summary/widget/pace_line_chart.dart';
import 'package:runmore/screen/run_summary/widget/pace_table.dart';
import 'package:runmore/util/run_format.dart';
import 'package:runmore/util/run_encoding.dart';

class RunSummaryScreen extends StatefulWidget {
  final RunStats stats;
  final List<NLatLng> path;
  final List<PaceSegment> segments;
  final DateTime startedAt;
  final DateTime endedAt;

  const RunSummaryScreen({
    super.key,
    required this.stats,
    required this.path,
    required this.segments,
    required this.startedAt,
    required this.endedAt,
  });

  factory RunSummaryScreen.fromLocalRun({Key? key, required Run run}) {
    final path = decodePath(run.pathJson);
    final segments = decodeSegments(run.segmentsJson);

    final stats = RunStats(
      distanceMeters: run.distanceMeters,
      elapsedSeconds: run.elapsedSeconds,
      avgSpeedMps: run.avgSpeedMps,
      isPaused: false,
    );

    return RunSummaryScreen(
      key: key,
      stats: stats,
      path: path,
      segments: segments,
      startedAt: run.startedAt,
      endedAt: run.endedAt,
    );
  }

  @override
  State<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends State<RunSummaryScreen> {
  NaverMapController? _mapController;
  NPathOverlay? _routeOverlay;

  // ✅ 마지막 partial 구간 분리 (거리 1km 미만이면 전부 대상)
  PaceSegment? _extractLastPartial(List<PaceSegment> all) {
    if (all.isEmpty) return null;
    final last = all.last;

    if (last.distance > 0 && last.distance < 1.0) {
      return last;
    }
    return null;
  }

  // ✅ 그래프/테이블에는 "완전 1km 구간"만 사용
  List<PaceSegment> _visibleSegments(List<PaceSegment> all) {
    if (all.isEmpty) return all;

    if (all.length == 1) return all;

    final last = all.last;
    if (last.distance > 0 && last.distance < 1.0) {
      return all.sublist(0, all.length - 1);
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final km = widget.stats.distanceMeters / 1000.0;
    final time = formatHms(widget.stats.elapsedSeconds);
    final pace = formatPaceFromMPerSec(widget.stats.avgSpeedMps);
    final segments = _visibleSegments(widget.segments);
    final lastPartial = _extractLastPartial(widget.segments);

    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceVariant.withOpacity(0.15);

    return Scaffold(
      appBar: AppBar(
        title: const Text('러닝 요약'),
      ),
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryCard(km, time, pace),
                    const SizedBox(height: 16),
                    _buildMapCard(),
                    const SizedBox(height: 16),
                    _buildPaceAnalysisCard(segments, lastPartial),
                  ],
                ),
              ),
            ),
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('완료'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── 요약 카드 ─────────────────
  Widget _buildSummaryCard(double km, String time, String pace) {
    final theme = Theme.of(context);

    final dateText = _formatDateRange(widget.startedAt, widget.endedAt);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⬆️ 맨 위에 날짜/시간
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 거리 / 시간 / 평균 페이스
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                label: '거리',
                value: km.toStringAsFixed(2),
                unit: 'km',
              ),
              _buildStatItem(
                label: '시간',
                value: time,
              ),
              _buildStatItem(
                label: '평균 페이스',
                value: pace,
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatItem({
    required String label,
    required String value,
    String? unit,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 3),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    String two(int v) => v.toString().padLeft(2, '0');
    final day =
        "${start.year}.${two(start.month)}.${two(start.day)} (${_weekdayKo(start.weekday)})";
    final startTime = "${two(start.hour)}:${two(start.minute)}";
    final endTime = "${two(end.hour)}:${two(end.minute)}";
    return '$day  $startTime ~ $endTime';
  }

  String _weekdayKo(int weekday) {
    const names = ['월', '화', '수', '목', '금', '토', '일'];
    return names[weekday - 1];
  }

  // ───────────────── 지도 카드 ─────────────────
  Widget _buildMapCard() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 제목 영역
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.route,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '달린 경로',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: widget.path.isNotEmpty
                      ? widget.path.first
                      : const NLatLng(37.5665, 126.9780),
                  zoom: 14,
                ),
                locationButtonEnable: false,
                scrollGesturesEnable: true,
                zoomGesturesEnable: true,
                rotationGesturesEnable: false,
              ),
              onMapReady: (controller) async {
                _mapController = controller;
                await _drawRouteAndFit();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── 페이스 분석 카드 ─────────────────
  Widget _buildPaceAnalysisCard(
      List<PaceSegment> segments,
      PaceSegment? lastPartial,
      ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.show_chart,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '페이스 분석',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 그래프
          PaceLineChart(segments: segments),
          const SizedBox(height: 12),
          // 테이블
          PaceTable(
            segments: segments,
            lastPartial: lastPartial,
          ),
        ],
      ),
    );
  }

  // ───────────────── 지도 경로 그리기 ─────────────────
  Future<void> _drawRouteAndFit() async {
    if (_mapController == null) return;

    final points = widget.path;
    if (points.isEmpty) return;

    if (points.length >= 2) {
      _routeOverlay = NPathOverlay(
        id: 'summary_route',
        coords: points,
        width: 6,
        color: Colors.blue,
      );
      await _mapController!.addOverlay(_routeOverlay!);
    }

    if (points.length == 1) {
      await _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(target: points.first, zoom: 16),
      );
    } else {
      final bounds = NLatLngBounds.from(points);
      final update = NCameraUpdate.fitBounds(
        bounds,
        padding: const EdgeInsets.all(40),
      );
      await _mapController!.updateCamera(update);
    }
  }
}
