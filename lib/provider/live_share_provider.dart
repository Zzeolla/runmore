import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:runmore/util/live_position_ext.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runmore/model/live_runner.dart';
import 'package:runmore/model/live_position.dart';
import 'package:runmore/model/room.dart';

class LiveShareProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  // ───────────────── 방 / 러너 / 세그먼트 상태 ─────────────────

  Room? _room;
  Room? get room => _room;

  List<LiveRunner> _runners = [];
  List<LiveRunner> get runners => List.unmodifiable(_runners);

  final Map<String, List<LivePosition>> _segmentsByRunner = {};
  Map<String, List<LivePosition>> get segmentsByRunner =>
      Map.unmodifiable(_segmentsByRunner);

  String? _myRunnerId;
  String? get myRunnerId => _myRunnerId;

  bool get isInRoom => _room != null;
  bool get isRunner => _myRunnerId != null;

  // “지금 달리는 중인지” (is_active)
  bool get isRunningNow {
    final id = _myRunnerId;
    if (id == null) return false;
    final me = _runners.where((r) => r.id == id).toList();
    if (me.isEmpty) return false;
    return me.first.isActive;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NaverMapController? _mapController;
  NaverMapController? get mapController => _mapController;

  bool get isOwner {
    final uid = _client.auth.currentUser?.id;
    final createdBy = _room?.createdBy;
    return uid != null && createdBy != null && uid == createdBy;
  }

  bool get iHaveCompletedRun {
    final id = _myRunnerId;
    if (id == null) return false;
    return hasCompletedRun(id);
  }

  void setMapController(NaverMapController controller) {
    _mapController = controller;
  }

  RealtimeChannel? _positionsChannel;
  RealtimeChannel? _roomChannel;

  // ───────────────── 내부 헬퍼 ─────────────────

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearRoomState() {
    _room = null;
    _runners = [];
    _segmentsByRunner.clear();
    _myRunnerId = null;
    _errorMessage = null;
    _unsubscribeRealtime();
    _unsubscribeRoomStatus();
  }

  bool hasCompletedRun(String runnerId) {
    final r = _runners.where((e) => e.id == runnerId).toList();
    if (r.isEmpty) return false;
    return r.first.runId != null;
  }

  // ✅ (핵심) 로그인 유저면 “참가자 row”를 무조건 보장 (is_active=false로 시작)
  Future<void> _ensureParticipantRowInactive() async {
    final room = _room;
    if (room == null) return;

    final uid = _client.auth.currentUser?.id;
    if (uid == null) return; // 비로그인 = 관람자 (DB row 없음)

    final displayName = await _getMyDisplayName();

    // 색상은 최초 생성 시만 할당 (이미 있으면 유지)
    final usedColors = _runners
        .map((r) => r.color ?? '')
        .where((c) => c.isNotEmpty)
        .toSet();
    final colorHex = _pickRunnerColor(usedColors);

    try {
      // ⚠️ 권장: DB에 unique(room_id, user_id) 걸고 upsert 쓰기
      // create unique index uniq_live_runners_room_user on public.live_runners(room_id, user_id);

      final upserted = await _client
          .from('live_runners')
          .upsert(
        {
          'room_id': room.id,
          'user_id': uid,
          'display_name': displayName,
          // 이미 존재하는 row에 color 덮어쓰기 싫으면 서버에서 coalesce 하거나,
          // 여기서는 “없을 때만”이 어려우니 일단 넣어도 OK.
          'color': colorHex,
          // ✅ 참가 시점엔 “달리는 중 아님”
          'is_active': false,
          'expired_at': room.expiredAt.toUtc().toIso8601String(),
        },
        onConflict: 'room_id,user_id',
      )
          .select()
          .single();

      final runner = LiveRunner.fromJson(Map<String, dynamic>.from(upserted));

      // 로컬 상태에 반영
      _myRunnerId = runner.id;

      // runners 목록 업데이트(있으면 교체, 없으면 추가)
      final idx = _runners.indexWhere((r) => r.id == runner.id);
      if (idx >= 0) {
        final next = [..._runners];
        next[idx] = runner;
        _runners = next;
      } else {
        _runners = [..._runners, runner];
      }

      _segmentsByRunner.putIfAbsent(runner.id, () => []);
      notifyListeners();
    } catch (e) {
      // 실패해도 앱은 관람자로 동작 가능하니 치명 에러로 만들 필요는 없음
      if (kDebugMode) {
        print('_ensureParticipantRowInactive error: $e');
      }
    }
  }

  Future<String> _getMyDisplayName() async {
    final user = _client.auth.currentUser;
    if (user == null) return 'Runner';

    // 1) auth metadata 우선
    final meta = user.userMetadata;
    final metaName = (meta?['name'] ??
        meta?['full_name'] ??
        meta?['nickname'] ??
        meta?['display_name'])
        ?.toString();
    if (metaName != null && metaName.trim().isNotEmpty) return metaName.trim();

    // 2) app_users 테이블 nickname
    try {
      final row = await _client
          .from('app_users')
          .select('nickname')
          .eq('id', user.id)
          .maybeSingle();

      final nick = row?['nickname']?.toString();
      if (nick != null && nick.trim().isNotEmpty) return nick.trim();
    } catch (_) {}

    // 3) fallback
    return 'Runner';
  }

  // ───────────────── 1) 공유 코드로 방 참가 ─────────────────
  Future<void> joinByShareCode(String shareCode) async {
    _setLoading(true);
    _clearRoomState();

    try {
      final result =
      await _client.rpc('get_live_state', params: {'p_share_code': shareCode});

      if (result == null) {
        throw Exception('라이브 정보를 찾을 수 없습니다.');
      }

      final data = Map<String, dynamic>.from(result as Map);

      // ── 1) room 파싱 ──
      final roomJson = Map<String, dynamic>.from(data['room']);
      _room = Room(
        id: roomJson['id'] as String,
        title: roomJson['title'] as String,
        shareCode: shareCode,
        writeToken: '',
        isActive: roomJson['is_active'] as bool? ?? true,
        createdBy: roomJson['created_by'] as String?, // 있으면 받기
        createdAt: DateTime.parse(roomJson['created_at'] as String),
        expiredAt: DateTime.parse(roomJson['expired_at'] as String),
        extendCount: roomJson['extend_count'] as int? ?? 0,
      );

      // ── 2) runners + segmentsByRunner 파싱 ──
      final runnersJson = (data['runners'] as List).cast<Map<String, dynamic>>();

      _runners = [];
      _segmentsByRunner.clear();

      for (final rjson in runnersJson) {
        final runnerId = (rjson['runner_id'] ?? rjson['id']) as String;

        final runner = LiveRunner(
          id: runnerId,
          roomId: _room!.id,
          userId: (rjson['user_id'] as String?) ?? '',
          displayName: (rjson['display_name'] as String?) ?? 'Runner',
          color: rjson['color'] as String?,
          isActive: (rjson['is_active'] as bool?) ?? false,
          createdAt: _parseTs(rjson['created_at']) ?? _room!.createdAt,
          runId: rjson['run_id'] as String?,
          expiredAt: _parseTs(rjson['expired_at']) ?? _room!.expiredAt,
          extendCount: (rjson['extend_count'] as int?) ?? 0,
        );

        _runners.add(runner);

        final segJsonList =
            (rjson['recent_segments'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        final segments = segJsonList
            .map((sjson) => LivePosition.fromJson(Map<String, dynamic>.from(sjson)))
            .toList();

        _segmentsByRunner[runnerId] = segments;
      }

      // ── 3) 내 runnerId 찾기(이미 runners에 포함되어 있으면) ──
      final uid = _client.auth.currentUser?.id;
      if (uid != null) {
        final mine = _runners.where((r) => r.userId == uid).toList();
        if (mine.isNotEmpty) {
          _myRunnerId = mine.first.id;
        }
      }

      // ── 4) realtime 구독 ──
      _subscribeRealtime(_room!.id);
      _subscribeRoomStatus(_room!.id);

      // ✅ (핵심) 로그인 유저면 “참가자 row”를 무조건 보장 (inactive)
      await _ensureParticipantRowInactive();

      _setError(null);
    } catch (e, st) {
      if (kDebugMode) {
        print('joinByShareCode error: $e\n$st');
      }
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ───────────────── 2) 방 생성 + 참가 ─────────────────
  Future<void> createAndJoinRoom({String? title}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw Exception('방 생성은 로그인 후 가능합니다.');
    }

    _setLoading(true);
    _clearRoomState();

    try {
      final rows = await _client.rpc('create_room', params: {'p_title': title}).select();

      if (rows.isEmpty) {
        throw Exception('create_room 결과가 비어 있습니다.');
      }

      final row = Map<String, dynamic>.from(rows.first);

      _room = Room(
        id: row['id'] as String,
        title: row['title'] as String,
        shareCode: row['share_code'] as String,
        writeToken: row['write_token'] as String,
        isActive: row['is_active'] as bool? ?? true,
        createdBy: row['created_by'] as String?, // 있으면 받기
        createdAt: DateTime.parse(row['created_at'] as String),
        expiredAt: DateTime.parse(row['expired_at'] as String),
        extendCount: row['extend_count'] as int? ?? 0,
      );

      _runners = [];
      _segmentsByRunner.clear();
      _myRunnerId = null;

      _subscribeRealtime(_room!.id);
      _subscribeRoomStatus(_room!.id);

      // ✅ (핵심) 방 만든 사람도 즉시 참가자 row 보장 (inactive)
      await _ensureParticipantRowInactive();

      _setError(null);
    } catch (e, st) {
      if (kDebugMode) {
        print('createAndJoinRoom error: $e\n$st');
      }
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ───────────────── 3) 달리기 시작/종료에 따른 is_active 토글 ─────────────────

  /// 달리기 시작 시 호출: is_active=true (+ run_id 연결하고 싶으면 전달)
  Future<void> setRunningActive({required bool active, String? runId}) async {
    final room = _room;
    if (room == null) throw Exception('방에 먼저 참여해야 합니다.');

    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('로그인이 필요합니다.');

    // 참가자 row 없을 수도 있으니 한번 보장
    await _ensureParticipantRowInactive();

    // 내 runnerId 확보
    final myId = _myRunnerId;
    if (myId == null) throw Exception('러너 참가자 정보를 찾을 수 없습니다.');

    final updateData = <String, dynamic>{
      'is_active': active,
    };
    if (runId != null) updateData['run_id'] = runId;

    final updated = await _client
        .from('live_runners')
        .update(updateData)
        .eq('id', myId)
        .select()
        .single();

    final runner = LiveRunner.fromJson(Map<String, dynamic>.from(updated));

    // 로컬 runners 교체
    final idx = _runners.indexWhere((r) => r.id == runner.id);
    if (idx >= 0) {
      final next = [..._runners];
      next[idx] = runner;
      _runners = next;
    } else {
      _runners = [..._runners, runner];
    }

    notifyListeners();
  }

  // ───────────────── 색상 선택 ─────────────────

  String _pickRunnerColor(Set<String> usedHex) {
    const candidates = [
      '#FF5722',
      '#FF9800',
      '#FFC107',
      '#4CAF50',
      '#03A9F4',
      '#3F51B5',
      '#9C27B0',
      '#E91E63',
    ];
    for (final c in candidates) {
      if (!usedHex.contains(c)) return c;
    }
    return candidates.first;
  }

  DateTime? _parseTs(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  // ───────────────── 4) Realtime 구독 (live_positions insert) ─────────────────

  void _subscribeRealtime(String roomId) {
    _unsubscribeRealtime();

    _positionsChannel = _client
        .channel('live_positions:room_$roomId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'live_positions',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) {
        final newRow = Map<String, dynamic>.from(payload.newRecord as Map);
        _handleNewLivePosition(newRow);
      },
    )
        .subscribe();
  }

  void _unsubscribeRealtime() {
    if (_positionsChannel != null) {
      _client.removeChannel(_positionsChannel!);
      _positionsChannel = null;
    }
  }

  void _handleNewLivePosition(Map<String, dynamic> row) {
    final pos = LivePosition.fromJson(row);
    final runnerId = pos.runnerId;

    final list = _segmentsByRunner[runnerId] ?? [];
    final updated = [pos, ...list];

    _segmentsByRunner[runnerId] = updated.take(3).toList();
    notifyListeners();
  }

  // ───────────────── 4-2) Realtime 구독 (rooms update) ─────────────────

  void _subscribeRoomStatus(String roomId) {
    _unsubscribeRoomStatus();

    _roomChannel = _client
        .channel('rooms:room_$roomId')
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'rooms',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: roomId,
      ),
      callback: (payload) {
        final row = Map<String, dynamic>.from(payload.newRecord as Map);
        final isActive = row['is_active'] as bool? ?? true;

        if (!isActive) {
          _clearRoomState();
          notifyListeners();
        } else {
          try {
            _room = Room.fromJson(row);
            notifyListeners();
          } catch (_) {}
        }
      },
    )
        .subscribe();
  }

  void _unsubscribeRoomStatus() {
    if (_roomChannel != null) {
      _client.removeChannel(_roomChannel!);
      _roomChannel = null;
    }
  }

  // ───────────────── 5) 방 나가기 /dispose ─────────────────

  void leaveRoom() {
    _clearRoomState();
    notifyListeners();
  }

  @override
  void dispose() {
    _unsubscribeRealtime();
    _unsubscribeRoomStatus();
    super.dispose();
  }

  // ───────────────── 6) 방 종료 시키기 / endRoom ─────────────────

  Future<void> endRoom() async {
    final room = _room;
    if (room == null) return;

    final uid = _client.auth.currentUser?.id;
    if (uid == null || room.createdBy != uid) {
      throw Exception('방장만 방을 종료할 수 있습니다.');
    }

    await _client.from('rooms').update({'is_active': false}).eq('id', room.id);

    _clearRoomState();
    notifyListeners();
  }

  // 지도에서 러너 클릭 시 포커싱 변경
  Future<void> focusRunner(String runnerId) async {
    if (_mapController == null) return;

    final segments = _segmentsByRunner[runnerId] ?? [];
    if (segments.isEmpty) return;

    final latest = segments.first;
    final lastPoint = latest.lastPoint;
    if (lastPoint == null) return;

    await _mapController!.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
        target: lastPoint,
        zoom: 15,
      ),
    );
  }
}
