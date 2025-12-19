import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/model/pace_segment.dart';
import 'package:runmore/model/run_stats.dart';
import 'package:runmore/model/run_tick.dart';
import 'package:runmore/service/run_service.dart';

class RunProvider extends ChangeNotifier {
  final RunService _svc = RunService();
  RunStats _stats = const RunStats(
    distanceMeters: 0,
    elapsedSeconds: 0,
    avgSpeedMps: 0,
    isPaused: false, // 👈 RunStats에 이 필드 있다고 가정
  );
  bool _isRunning = false;
  final List<NLatLng> _path = [];
  final List<RunTick> _ticks = [];
  final List<PaceSegment> _segments = [];
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  bool _ttsBlocked = false;
  bool _wasAutoPaused = false;
  DateTime? _lastTtsAt;

  DateTime? _startedAt;
  DateTime? _endedAt;

  // 스트림 구독 저장용
  StreamSubscription<RunStats>? _statsSub;
  StreamSubscription<RunTick>? _tickSub;
  StreamSubscription<PaceSegment>? _segSub;
  StreamSubscription<Map<String, dynamic>>? _pauseSub;

  RunStats get stats => _stats;
  bool get isRunning => _isRunning;
  bool get isPaused => _stats.isPaused;
  List<NLatLng> get path => List.unmodifiable(_path);
  List<RunTick> get ticks => List.unmodifiable(_ticks);
  List<PaceSegment> get segments => List.unmodifiable(_segments);
  DateTime? get startedAt => _startedAt;
  DateTime? get endedAt => _endedAt;

  Future<bool> ensurePermission() => _svc.ensurePermission();

  Future<void> start() async {
    if (_isRunning) return;

    _startedAt = DateTime.now();
    _endedAt = null;

    // 1) 새 런 시작이니까 내부 상태 초기화
    _stats = const RunStats(
      distanceMeters: 0,
      elapsedSeconds: 0,
      avgSpeedMps: 0,
      isPaused: false,
    );
    _ticks.clear();
    _path.clear();
    _segments.clear();
    _ttsBlocked = false;
    _wasAutoPaused = false;
    _lastTtsAt = null;
    notifyListeners();

    // 2) 포그라운드 서비스 시작
    _isRunning = true;
    notifyListeners();

    await _svc.start();

    // 3) 예전 구독 있으면 끊고, 새로 구독
    await _statsSub?.cancel();
    await _tickSub?.cancel();
    await _segSub?.cancel();
    await _pauseSub?.cancel();

    _statsSub = _svc.statsStream.listen((s) {
      _stats = s;
      notifyListeners();
    });

    _tickSub = _svc.tickStream.listen((t) {
      if (t.isPaused) return;
      _ticks.add(t);
      _path.add(NLatLng(t.lat, t.lng));
      notifyListeners();
    });

    _segSub = _svc.segmentStream.listen((seg) async {
      // 러닝 중 아닐 때 늦게 도착하는 이벤트 방지
      if (!_isRunning) return;

      // pause 중이면 말 안 하게(취향)
      // if (_stats.isPaused) return;

      if (_segments.isNotEmpty) {
        final last = _segments.last;
        if (last.index == seg.index &&
            last.distance == seg.distance &&
            last.seconds == seg.seconds) {
          return;
        }
      }

      _segments.add(seg);
      notifyListeners();

      final text = _buildKmTtsText(seg);
      if (text != null) {
        await _speak(text);
      }
    });

    _pauseSub = _svc.pauseEventStream.listen((e) async {
      if (!_isRunning) return;

      // TaskHandler가 보내는 payload 기준
      final isPaused = e['isPaused'] == true;
      final autoPaused = e['autoPaused'] == true;
      final userPaused = e['userPaused'] == true;

      // ✅ pause면 TTS 막기 / resume면 풀기
      _ttsBlocked = isPaused;

      // ✅ 자동 일시정지 진입: 딱 1회 안내
      if (isPaused && autoPaused && !_wasAutoPaused) {
        _wasAutoPaused = true;

        // 수동 pause가 아닌 경우에만 "자동" 안내
        if (!userPaused) {
          _ttsBlocked = false;       // 말할 때만 잠깐 허용
          await _speak('자동 일시정지');
          _ttsBlocked = true;
        }
        return;
      }

      // ✅ 자동 재개: 딱 1회 안내 + 차단 해제
      if (!isPaused && _wasAutoPaused) {
        _wasAutoPaused = false;

        _ttsBlocked = false;
        await _speak('자동 재개');
        return;
      }
    });
  }

  Future<void> stop() async {
    if (!_isRunning) return;

    _endedAt = DateTime.now();

    _isRunning = false;
    _stats = RunStats(
      distanceMeters: _stats.distanceMeters,
      elapsedSeconds: _stats.elapsedSeconds,
      avgSpeedMps: _stats.avgSpeedMps,
      isPaused: false,
    );
    notifyListeners();

    await _svc.stop();

    // 필요하면 여기서도 구독 정리
    await _statsSub?.cancel();
    await _tickSub?.cancel();
    await _segSub?.cancel();
    await _pauseSub?.cancel();
    _pauseSub = null;
  }

  void pause() {
    if (!_isRunning || _stats.isPaused) return;

    // 1️⃣ 로컬 상태 먼저 pause로 바꿔서 UI 즉시 멈추게
    _stats = RunStats(
      distanceMeters: _stats.distanceMeters,
      elapsedSeconds: _stats.elapsedSeconds,
      avgSpeedMps: _stats.avgSpeedMps,
      isPaused: true,
    );
    notifyListeners();

    // 2️⃣ 백그라운드 서비스에 명령 전송
    _svc.pause();
  }

  void resume() {
    if (!_isRunning || !_stats.isPaused) return;

    // 1️⃣ 로컬 상태 먼저 resume으로
    _stats = RunStats(
      distanceMeters: _stats.distanceMeters,
      elapsedSeconds: _stats.elapsedSeconds,
      avgSpeedMps: _stats.avgSpeedMps,
      isPaused: false,
    );
    notifyListeners();

    // 2️⃣ 백그라운드 서비스 재개
    _svc.resume();
  }

  Future<void> restoreFromRunningService() async {
    // 이미 러닝 중이면 중복 복구 방지
    if (_isRunning) return;

    final isServiceRunning = await FlutterForegroundTask.isRunningService;
    if (!isServiceRunning) return;

    // ✅ "새로 시작"이 아니라 "복구"이므로 reset 하지 않는다
    _isRunning = true;
    _endedAt = null;
    _ttsBlocked = false;
    notifyListeners();

    // ✅ 구독만 다시 연결
    await _statsSub?.cancel();
    await _tickSub?.cancel();
    await _segSub?.cancel();
    await _pauseSub?.cancel();

    _statsSub = _svc.statsStream.listen((s) {
      _stats = s;

      // startedAt을 저장 안 했으면, 일단 elapsed 기반으로 “추정” 가능
      _startedAt ??= DateTime.now().subtract(Duration(seconds: s.elapsedSeconds));

      notifyListeners();
    });

    _tickSub = _svc.tickStream.listen((t) {
      if (t.isPaused) return;
      _ticks.add(t);
      _path.add(NLatLng(t.lat, t.lng));
      notifyListeners();
    });

    _segSub = _svc.segmentStream.listen((seg) async {
      if (!_isRunning) return;
      _segments.add(seg);
      notifyListeners();
    });

    _pauseSub = _svc.pauseEventStream.listen((e) async {
      if (!_isRunning) return;
      final isPaused = e['isPaused'] == true;
      _ttsBlocked = isPaused;
      notifyListeners();
    });

    // ✅ 백그라운드에 “현재 상태 한 번 보내줘”
    _svc.requestState();
  }

  Future<void> restoreFromRunningDb(AppDatabase db) async {
    // 1) state
    final state = await (db.select(db.runningState)
      ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (state != null) {
      _startedAt = state.startedAt;
      _stats = RunStats(
        distanceMeters: state.distanceMeters,
        elapsedSeconds: state.elapsedSeconds,
        avgSpeedMps: state.avgSpeedMps,
        isPaused: state.isPaused,
      );
    }

    // 2) ticks
    final ticks = await (db.select(db.runningTicks)
      ..orderBy([(t) => drift.OrderingTerm(expression: t.seq)]))
        .get();

    _ticks.clear();
    _path.clear();

    for (final r in ticks) {
      _ticks.add(RunTick(
        ts: r.ts,
        lat: r.lat,
        lng: r.lng,
        altitude: r.altitude,
        speedMps: r.speedMps ?? 0.0,
        isPaused: r.isPaused,
      ));
      if (!r.isPaused) {
        _path.add(NLatLng(r.lat, r.lng));
      }
    }

    notifyListeners();
  }


  void resetPath() {
    _path.clear();
    notifyListeners();
  }

  void resetSegments() {
    _segments.clear();
    notifyListeners();
  }

  Future<void> _initTtsIfNeeded() async {
    if (_ttsReady) return;
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _ttsReady = true;
  }

  Future<void> _speak(String text) async {
    if (_ttsBlocked) return;
    if (!_canSpeak()) return;

    await _initTtsIfNeeded();
    await _tts.stop(); // 겹침 방지(원하면 제거)
    _lastTtsAt = DateTime.now();
    await _tts.speak(text);
  }

  String? _buildKmTtsText(PaceSegment seg) {
    // ✅ 1km 구간만 음성 안내 (partial은 원하면 제외)
    if (seg.distance < 0.99) return null;

    // 1) 구간 페이스(mm:ss)
    final paceSecPerKm = seg.seconds; // 1km 기준이면 seconds가 그대로 pace
    final segMin = paceSecPerKm ~/ 60;
    final segSec = paceSecPerKm % 60;

    // 2) 총 시간 (cumulativeSeconds 기반이 더 자연스러움)
    final total = seg.cumulativeSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;

    final paceText = '$segMin분 ${segSec}초';

    // h가 0이면 “0시간”은 말하지 않기
    final totalTimeText = h > 0
        ? '$h시간 $m분 ${s}초'
        : '$m분 ${s}초';
    // TODO : 목표가 있다면 나중에 추가하기
    // TODO: 심박수도 추가 가능하다면 추가하기
    return '구간${seg.index} 구간 페이스 $paceText, 총 ${seg.index}키로 $totalTimeText';
  }

  bool _canSpeak({int cooldownMs = 1200}) {
    final now = DateTime.now();
    if (_lastTtsAt == null) return true;
    return now.difference(_lastTtsAt!).inMilliseconds >= cooldownMs;
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    _tickSub?.cancel();
    _segSub?.cancel();
    _pauseSub?.cancel();
    _tts.stop();
    _svc.dispose();
    super.dispose();
  }
}
