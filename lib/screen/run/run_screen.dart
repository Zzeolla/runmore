import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/provider/live_share_provider.dart';
import 'package:runmore/provider/run_provider.dart';
import 'package:runmore/provider/user_provider.dart';
import 'package:runmore/screen/run/run_home_summary_loader.dart';
import 'package:runmore/screen/run/run_map_view.dart';
import 'package:runmore/screen/run/widget/guset_limit_dialog.dart';
import 'package:runmore/screen/run/widget/run_bottom_guest_card.dart';
import 'package:runmore/screen/run/widget/run_bottom_summary_card.dart';
import 'package:runmore/screen/run/widget/stats_panel.dart';
import 'package:runmore/screen/run_summary/run_summary_screen.dart';
import 'package:runmore/util/pace_segment.dart';
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
  Timer? _uiTimer;
  int _uiElapsedSeconds = 0;
  bool _lastIsRunning = false;
  bool _lastIsPaused = false;
  VoidCallback? _runListener;

  // 로그인 요약용
  Future<RunHomeSummary>? _summaryFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final run = context.read<RunProvider>();

    if (_runListener != null) {
      run.removeListener(_runListener!);
    }

    _runListener = () {
      if (!mounted) return;
      _syncUiTimer(run);
    };

    run.addListener(_runListener!);

    final user = context.read<UserProvider>();
    if (user.isLoggedIn && _summaryFuture == null) {
      final db = context.read<AppDatabase>();
      _summaryFuture = RunHomeSummaryLoader().loadFromLocal(db);
    }
  }

  @override
  void dispose() {
    final run = context.read<RunProvider>();
    if (_runListener != null) {
      run.removeListener(_runListener!);
    }
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunProvider>();
    final user = context.watch<UserProvider>();

    final backendSecs = run.stats.elapsedSeconds;
    final displaySecs = run.isRunning ? _uiElapsedSeconds : backendSecs;

    final km = run.stats.distanceMeters / 1000.0;
    final pace = formatPaceFromMPerSec(run.stats.avgSpeedMps);
    final time = formatElapsed(displaySecs);

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
                final user = context.read<UserProvider>();
                final live = context.read<LiveShareProvider>();

                if (!user.isLoggedIn) {
                  await showGuestLimitDialog(context);
                }

                final ok = await run.ensurePermission();
                if (!ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('위치 권한을 허용해 주세요.')),
                  );
                  return;
                }

                run.resetPath();

                // 새 런 시작이니 UI 타이머도 0으로
                await run.start();
                setState(() => _uiElapsedSeconds = run.stats.elapsedSeconds);

                // ✅ 라이브 방에 들어가 있고 + 로그인이라면 “달리는 중” ON
                if (user.isLoggedIn && live.isInRoom) {
                  await live.setRunningActive(active: true);
                }
              },
              onPause: run.pause,
              onResume: run.resume,
              onStop: () async {
                final user = context.read<UserProvider>();
                final live = context.read<LiveShareProvider>();

                final stats = run.stats;
                final path = run.path;

                if (stats.distanceMeters < kMinAutoSaveM) {
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
                final endedAt = run.endedAt!;
                final segments = buildPaceSegments(run.ticks);

                if (user.isLoggedIn) {
                  // TODO: Supabase 저장 로직 반영 예정
                } else {
                  final db = context.read<AppDatabase>();

                  // 기존 기록 3개 제한
                  final existingRuns = await (db.select(db.runs)
                    ..orderBy([
                          (tbl) => drift.OrderingTerm(
                        expression: tbl.createdAt,
                        mode: drift.OrderingMode.asc,
                      ),
                    ]))
                      .get();

                  if (existingRuns.length >= 3) {
                    final oldest = existingRuns.first;
                    await db.delete(db.runs).delete(oldest);
                  }

                  final runId = const Uuid().v4();

                  await db.into(db.runs).insert(
                    RunsCompanion.insert(
                      id: runId,
                      startedAt: startedAt,
                      endedAt: endedAt,
                      distanceMeters: stats.distanceMeters,
                      elapsedSeconds: stats.elapsedSeconds,
                      avgSpeedMps: stats.avgSpeedMps,
                      calories: const drift.Value(null),
                      pathJson: encodePath(path),
                      segmentsJson: encodeSegments(segments),
                    ),
                  );
                }

                // ✅ 라이브 방 + 로그인: 달리기 종료 + (저장 성공했으면) run_id 남기기
                if (user.isLoggedIn && live.isInRoom) {
                  await live.setRunningActive(active: false);
                }


                // 요약 화면 이동
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RunSummaryScreen(
                      stats: stats,
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
        ],
      ),
    );
  }

  // ---------------------------
  // UI 타이머 (표시용)
  // ---------------------------

  void _syncUiTimer(RunProvider run) {
    final isRunning = run.isRunning;
    final isPaused = run.isPaused;

    if (isRunning && !_lastIsRunning) {
      _uiElapsedSeconds = run.stats.elapsedSeconds;
      _startUiTimer();
    }

    if (!isRunning && _lastIsRunning) {
      _stopUiTimer();
      _uiElapsedSeconds = run.stats.elapsedSeconds;
    }

    // ✅ pause/resume 변화 처리
    if (isRunning && _lastIsRunning) {
      // pause로 바뀜 -> 타이머 멈춤 + backend로 고정
      if (isPaused && !_lastIsPaused) {
        _stopUiTimer();
        _uiElapsedSeconds = run.stats.elapsedSeconds;
      }

      // resume으로 바뀜 -> backend로 맞춘 뒤 타이머 재개
      if (!isPaused && _lastIsPaused) {
        _uiElapsedSeconds = run.stats.elapsedSeconds;
        _startUiTimer();
      }
    }

    _lastIsRunning = isRunning;
    _lastIsPaused = isPaused;
  }

  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final run = context.read<RunProvider>();

      if (!run.isRunning || run.isPaused) return;

      setState(() => _uiElapsedSeconds++);

      final backend = run.stats.elapsedSeconds;

      // 백엔드가 훨씬 앞서가면 따라잡기
      if (backend - _uiElapsedSeconds > 3) {
        setState(() => _uiElapsedSeconds = backend);
      }
    });
  }

  void _stopUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = null;
  }
}
