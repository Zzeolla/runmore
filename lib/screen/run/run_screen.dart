import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/model/run_record.dart';
import 'package:runmore/provider/health_summary_provider.dart';
import 'package:runmore/provider/live_share_provider.dart';
import 'package:runmore/provider/run_provider.dart';
import 'package:runmore/provider/user_provider.dart';
import 'package:runmore/repository/local_run_repository.dart';
import 'package:runmore/repository/supabase_run_repository.dart';
import 'package:runmore/screen/run/run_home_summary_loader.dart';
import 'package:runmore/screen/run/run_map_view.dart';
import 'package:runmore/screen/run/widget/countdown_overlay.dart';
import 'package:runmore/screen/run/widget/guset_limit_dialog.dart';
import 'package:runmore/screen/run/widget/run_bottom_guest_card.dart';
import 'package:runmore/screen/run/widget/run_bottom_summary_card.dart';
import 'package:runmore/screen/run/widget/stats_panel.dart';
import 'package:runmore/screen/run_summary/run_summary_screen.dart';
import 'package:runmore/util/location_permission_ui.dart';
import 'package:runmore/util/run_encoding.dart';
import 'package:runmore/util/run_format.dart';
import 'package:runmore/widget/snackbar.dart';
import 'package:uuid/uuid.dart';

const double kMinAutoSaveM = 500;

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  Future<RunHomeSummary>? _summaryFuture;

  bool _showOverlay = false;
  int _overlaySeconds = 5;
  Timer? _overlayTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = context.read<UserProvider>();
    if (user.isLoggedIn && _summaryFuture == null) {
      final db = context.read<AppDatabase>();
      _summaryFuture = RunHomeSummaryLoader().loadFromLocal(db);
    }
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunProvider>();
    final user = context.watch<UserProvider>();

    final elapsed = run.stats.elapsedSeconds;
    final km = run.stats.distanceMeters / 1000.0;

    final pace = _formatPaceOrDash(run.stats.avgSpeedMps, elapsed);
    final time = formatElapsed(elapsed);

    return Scaffold(
      appBar: AppBar(title: const Text('런모아')),
      body: Stack(
        children: [
          // ✅ 지도/오버레이는 별도 위젯으로 분리
          RunMapView(path: run.path),

          // ✅ 상단 패널은 그대로 (컨트롤 로직은 아직 여기)
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: StatsPanel(
              km: km,
              pace: pace,
              time: time,
              isRunning: run.isRunning,
              isPaused: run.isPaused,
              onStart: () async {
                if (_showOverlay || run.isSessionActive) return;

                final user = context.read<UserProvider>();
                final live = context.read<LiveShareProvider>();

                if (!user.isLoggedIn) {
                  await showGuestLimitDialog(context);
                }

                final ok = await ensureRunLocationPermissionWithUi(context);
                if (!ok) return;

                // ✅ 1) preStart 먼저
                try {
                  await run.preStart();
                } catch (_) {
                  if (!mounted) return;
                  showRunSnackBar(
                    context,
                    icon: '⚠️',
                    message: '러닝 준비에 실패했습니다. 알림/배터리 설정을 확인해 주세요.',
                  );
                  return;
                }

                // ✅ 2) 카운트다운 시작
                run.resetPath();
                _startOverlayCountdown(
                  seconds: 5,
                  onDone: () async {
                    // ✅ 3) 카운트다운 끝나면 startRun
                    await run.startRun();

                    if (user.isLoggedIn && live.isInRoom) {
                      await live.setRunningActive(active: true);
                    }
                  },
                );
              },
              onPause: run.pause,
              onResume: run.resume,
              onStop: () async {
                if (_showOverlay) return;

                final user = context.read<UserProvider>();
                final live = context.read<LiveShareProvider>();
                final health = context.read<HealthSummaryProvider>();

                final stats = run.stats;
                final path = run.path;
                final distanceMeters = stats.distanceMeters;

                if (distanceMeters < kMinAutoSaveM) {
                  await run.stop();

                  if (user.isLoggedIn && live.isInRoom) {
                    await live.setRunningActive(active: false);
                  }
                  if (!mounted) return;

                  showRunSnackBar(
                    context,
                    icon: '⛔',
                    message: '${kMinAutoSaveM.toInt()}m 미만 거리의 러닝은 저장되지 않습니다.',
                  );
                  return;
                }

                final startedAt = run.startedAt!;
                await run.stop();
                final endedAt = run.endedAt ?? DateTime.now();
                final segments = run.segments;

                final summary = await health.fetchNearestSummary(
                  startedAt: startedAt,
                  endedAt: endedAt,
                  distanceMeters: distanceMeters,
                );

                // ✅ stats에 health summary 합치기 (copyWith에 calories/avgHr/avgCadence 추가한 버전 기준)
                final enrichedStats = stats.copyWith(
                  calories: summary?.calories,
                  avgHr: summary?.avgHr,
                  avgCadence: summary?.avgCadence,
                );

                if (user.isLoggedIn) {
                  final runId = const Uuid().v4();

                  // ✅ encode -> jsonDecode 해서 jsonb(List<Map>)로 넣기
                  final pathJson = (jsonDecode(encodePath(path)) as List)
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList();

                  final segmentsJson = (jsonDecode(encodeSegments(segments)) as List)
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList();

                  final record = RunRecord(
                    id: runId,
                    userId: user.userId!,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    distanceM: enrichedStats.distanceMeters,
                    elapsedS: enrichedStats.elapsedSeconds,
                    avgSpeedMps: enrichedStats.avgSpeedMps,
                    calories: enrichedStats.calories,
                    avgHr: enrichedStats.avgHr,
                    avgCadence: enrichedStats.avgCadence,
                    pathJson: pathJson,
                    segmentsJson: segmentsJson,
                    liveRoomId: live.isInRoom ? live.room!.id : null,
                    createdAt: DateTime.now(),
                  );

                  await SupabaseRunRepository().upsertRun(record);

                  // ✅ 라이브면 종료 + 이번 runId 연결까지
                  if (live.isInRoom) {
                    await live.setRunningActive(active: false, runId: runId);
                  }
                } else {
                  final db = context.read<AppDatabase>();
                  final repo = LocalRunRepository(db);

                  final runId = const Uuid().v4();

                  await repo.saveRunWithLimit(
                    RunsCompanion.insert(
                      id: runId,
                      startedAt: startedAt,
                      endedAt: endedAt,
                      distanceMeters: stats.distanceMeters,
                      elapsedSeconds: stats.elapsedSeconds,
                      avgSpeedMps: stats.avgSpeedMps,
                      calories: drift.Value(summary?.calories),
                      avgHr: drift.Value(summary?.avgHr),
                      avgCadence: drift.Value(summary?.avgCadence),
                      pathJson: encodePath(path),
                      segmentsJson: encodeSegments(segments),
                    ),
                    maxKeep: 3,
                  );
                }

                // 요약 화면 이동
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RunSummaryScreen(
                      stats: enrichedStats,
                      path: path,
                      segments: segments,
                      startedAt: startedAt,
                      endedAt: endedAt,
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ 하단 패널 분기: 게스트 / 로그인 요약
          if (!user.isLoggedIn)
            const RunBottomGuestCard()
          else if (_summaryFuture != null)
            FutureBuilder<RunHomeSummary>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                return RunBottomSummaryCard(snapshot: snapshot);
              },
            ),
          if (_showOverlay) CountdownOverlay(seconds: _overlaySeconds),
        ],
      ),
    );
  }


  // ---------------------------
  // overlay countdown
  // ---------------------------

  void _startOverlayCountdown({
    required int seconds,
    required Future<void> Function() onDone,
  }) {
    _overlayTimer?.cancel();

    setState(() {
      _showOverlay = true;
      _overlaySeconds = seconds; // 3부터 시작
    });

    _overlayTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;

      // 3 -> 2 -> 1 -> 0(START 표시) -> 종료
      final next = _overlaySeconds - 1;
      setState(() => _overlaySeconds = next);

      if (next <= 0) {
        // START를 잠깐 보여주고 싶으면 여기서 딜레이를 주면 됨
        t.cancel();
        _overlayTimer = null;

        // START를 250ms 보여주고 시작(원하면 0으로)
        await Future.delayed(const Duration(milliseconds: 250));

        if (!mounted) return;
        setState(() => _showOverlay = false);

        await onDone();
      }
    });
  }

  String _formatPaceOrDash(double avgSpeedMps, int elapsedSeconds) {
    if (elapsedSeconds <= 0) return '--:--';
    if (!avgSpeedMps.isFinite || avgSpeedMps < 0.8) return '--:--';
    return formatPaceFromMPerSec(avgSpeedMps);
  }
}
