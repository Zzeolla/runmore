import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/provider/run_provider.dart';
import 'package:runmore/provider/user_provider.dart';
import 'package:runmore/screen/login_screen.dart';
import 'package:runmore/screen/run_summary_screen.dart';
import 'package:runmore/util/run_format.dart';
import 'package:runmore/util/pace_segment.dart';
import 'package:runmore/util/run_encoding.dart';
import 'package:runmore/widget/guest_limit_dialog.dart';
import 'package:runmore/widget/snackbar.dart';
import 'package:runmore/widget/stats_panel.dart';
import 'package:uuid/uuid.dart';

const double kMinAutoSaveM = 500;

class _RunHomeSummary {
  final double weekKm;
  final double monthKm;
  final List<Run> recentRuns; // drift runs 테이블 dataClass TODO: 나중에 슈파베이스 db type으로 변경 필요할듯?

  _RunHomeSummary({
    required this.weekKm,
    required this.monthKm,
    required this.recentRuns,
  });
}

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  NaverMapController? _mapController;
  NPathOverlay? _routeOverlay;

  Timer? _uiTimer;
  int _uiElapsedSeconds = 0;
  bool _lastIsRunning = false;
  bool _lastIsPaused = false;

  // 👇 요약 패널용 Future (로그인일 때만 사용)
  Future<_RunHomeSummary>? _summaryFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = context.read<UserProvider>();

    // 로그인 상태일 때만 요약 데이터 로드
    if (user.isLoggedIn && _summaryFuture == null) {
      final db = context.read<AppDatabase>();

      // TODO: 현재는 임시로 로컬 Drift DB에서 로드
      // 향후 Supabase 러닝 테이블이 생기면 이 부분을
      // Supabase 요약 조회 로직으로 교체할 예정.
      _summaryFuture = _loadSummaryFromLocal(db);
    }
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunProvider>();
    final user = context.watch<UserProvider>();

    _syncUiTimer(run); // ← 이 줄 추가

    final backendSecs = run.stats.elapsedSeconds;
    if (!run.isRunning) {
      // 정지 상태에서는 항상 백엔드 값과 동일하게
      _uiElapsedSeconds = backendSecs;
    }
    final displaySecs = run.isRunning ? _uiElapsedSeconds : backendSecs;

    final km = run.stats.distanceMeters / 1000.0;
    final pace = formatPaceFromMPerSec(run.stats.avgSpeedMps);
    final time = formatElapsed(displaySecs);

    _updateRoute(run.path);

    return Scaffold(
      appBar: AppBar(title: const Text('런모아')),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: run.path.isNotEmpty ? run.path.last : const NLatLng(37.5665, 126.9780),
                zoom: 15,
              ),
              locationButtonEnable: true,
              scaleBarEnable: true,
              rotationGesturesEnable: false,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              // 현재 위치 추적 모드: 지도 카메라 따라가기(Follow) 원하면 아래 사용
              controller.setLocationTrackingMode(NLocationTrackingMode.follow);

              // 🔹 경로가 "2개 이상" 있을 때만 오버레이 생성
              if (run.path.length >= 2) {
                _routeOverlay = NPathOverlay(
                  id: 'route',
                  coords: run.path,
                  width: 6,
                  color: Colors.blue,
                );
                await _mapController!.addOverlay(_routeOverlay!);
              }

              // 경로가 있다면 카메라 이동 (이 함수는 Future<bool> 반환)
              if (run.path.isNotEmpty) {
                await _mapController!.updateCamera(
                  NCameraUpdate.scrollAndZoomTo(target: run.path.last, zoom: 16),
                );
              }
            },
          ),

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

                if (!user.isLoggedIn) {
                  await showGuestLimitDialog(context);
                }

                final ok = await run.ensurePermission();
                if (!ok && mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('위치 권한을 허용해 주세요.')));
                  return;
                }
                run.resetPath();

                // 🔹 새 런 시작이니 UI 타이머도 0으로
                setState(() {
                  _uiElapsedSeconds = 0;
                });

                await run.start();
              },
              onPause: run.pause,
              onResume: run.resume,
              onStop: () async {
                final user = context.read<UserProvider>();
                // 현재 러닝 결과 스냅샷 먼저 가져오기
                final stats = run.stats;
                final path = run.path;

                if (stats.distanceMeters < kMinAutoSaveM) {
                  await run.stop();

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
                  // ─────────────────────────────
                  // 🔹 로그인 유저 → Supabase에 저장 예정
                  // ─────────────────────────────
                  // TODO: 추후 Provider를 통해 슈파베이스 저장 로직 반영
                } else {
                  final db = context.read<AppDatabase>();

                  // 1) 현재 저장된 기록들을 시작 시간 기준 오름차순(가장 오래된 것 먼저)으로 가져오기
                  final existingRuns = await (db.select(db.runs)
                    ..orderBy([
                          (tbl) => drift.OrderingTerm(
                        expression: tbl.createdAt,
                        mode: drift.OrderingMode.asc,
                      ),
                    ]))
                      .get();

                  if (existingRuns.length >= 3) {
                    // 2) 3개 이상이면 가장 오래된 기록 하나 삭제
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
                      calories: const drift.Value(null), // 나중에 계산해서 넣고 싶으면 여기서
                      pathJson: encodePath(path),
                      segmentsJson: encodeSegments(segments),
                    ),
                  );
                }

                if (mounted) {
                  setState(() {
                    // TODO: 로그인 전에는 사용 안 함. 로그인 후 Supabase 연동 시 참고.
                    // _summaryFuture = _loadSummaryFromLocal(db);
                  });
                }

                // 요약 화면으로 이동
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
          // 3) 하단 패널: 게스트 / 로그인 분기
          if (!user.isLoggedIn)
            _buildBottomGuestCard(context)
          else if (_summaryFuture != null)
            FutureBuilder<_RunHomeSummary>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                return _buildBottomSummaryCard(context, snapshot);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _updateRoute(List<NLatLng> points) async {
    if (_mapController == null) return;

    if (points.length < 2) {
      // 첫 점 하나만 있을 때는 경로를 그리지 않는다.
      return;
    }

    // 경로 좌표 갱신
    _routeOverlay = NPathOverlay(id: 'route', coords: points, width: 6, color: Colors.blue);
    await _mapController!.addOverlay(_routeOverlay!); // 같은 id로 업데이트

    // 카메라를 최신 좌표로 부드럽게 이동
    await _mapController!.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: points.last, zoom: 16),
    );
  }

  void _syncUiTimer(RunProvider run) {
    final isRunning = run.isRunning;
    final isPaused = run.isPaused;

    // 러닝 시작 시점
    if (isRunning && !_lastIsRunning) {
      _uiElapsedSeconds = run.stats.elapsedSeconds;
      _startUiTimer();
    }

    // 러닝 종료 시점
    if (!isRunning && _lastIsRunning) {
      _stopUiTimer();
      _uiElapsedSeconds = run.stats.elapsedSeconds;
    }

    // 일시정지/재개 변화는 타이머 콜백에서 처리
    _lastIsRunning = isRunning;
    _lastIsPaused = isPaused;
  }

  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final run = context.read<RunProvider>();

      // 러닝 중이 아니거나 일시정지면 표시용 초도 멈춤
      if (!run.isRunning || run.isPaused) return;

      setState(() {
        _uiElapsedSeconds++;
      });

      final backend = run.stats.elapsedSeconds;

      // 🔹 백엔드가 훨씬 "앞으로" 가 있을 때만 한 번에 따라잡기
      if (backend - _uiElapsedSeconds > 3) {
        _uiElapsedSeconds = backend;
      }
    });
  }

  void _stopUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = null;
  }
  Future<_RunHomeSummary> _loadSummaryFromLocal(AppDatabase db) async {
    final now = DateTime.now();

    // 이번주: 월요일 0시 ~ 지금
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    // 이번달: 1일 0시 ~ 지금
    final monthStart = DateTime(now.year, now.month, 1);

    final weekRuns = await (db.select(db.runs)
      ..where((tbl) => tbl.startedAt.isBiggerOrEqualValue(weekStart)))
        .get();

    final monthRuns = await (db.select(db.runs)
      ..where((tbl) => tbl.startedAt.isBiggerOrEqualValue(monthStart)))
        .get();

    final weekKm = weekRuns.fold<double>(
      0,
          (prev, r) => prev + r.distanceMeters,
    ) /
        1000.0;

    final monthKm = monthRuns.fold<double>(
      0,
          (prev, r) => prev + r.distanceMeters,
    ) /
        1000.0;

    final recentRuns = await (db.select(db.runs)
      ..orderBy([
            (tbl) => drift.OrderingTerm(
          expression: tbl.startedAt,
          mode: drift.OrderingMode.desc,
        ),
      ])
      ..limit(3))
        .get();

    return _RunHomeSummary(
      weekKm: weekKm,
      monthKm: monthKm,
      recentRuns: recentRuns,
    );
  }

  Widget _buildBottomSummaryCard(
      BuildContext context,
      AsyncSnapshot<_RunHomeSummary> snapshot,
      ) {
    if (!snapshot.hasData) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 80,
            ),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    }

    final data = snapshot.data!;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 80,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.15),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이번주 / 이번달
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryChip(
                        label: '이번주',
                        km: data.weekKm,
                        textTheme: textTheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryChip(
                        label: '이번달',
                        km: data.monthKm,
                        textTheme: textTheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '최근 러닝',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...data.recentRuns.map((run) {
                  final distanceKm = (run.distanceMeters / 1000.0);
                  final elapsed = formatHms(run.elapsedSeconds);
                  final dateStr = formatDate(run.startedAt);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        // TODO: 여기 나중에 지도 썸네일 (Naver Static Map 등)으로 교체
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: Colors.blueGrey[100],
                            child: const Icon(
                              Icons.map,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${distanceKm.toStringAsFixed(2)} km',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$elapsed · $dateStr',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}