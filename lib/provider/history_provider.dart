import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:runmore/db/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryProvider extends ChangeNotifier {
  final AppDatabase db;
  final SupabaseClient client;

  HistoryProvider({
    required this.db,
    SupabaseClient? client,
  }) : client = client ?? Supabase.instance.client;

  // 외부 주입 (UserProvider에서 전달)
  String? _userId;
  bool _isLoggedIn = false;

  // UI 상태
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<Run> _runs = [];

  static const int _pageSize = 10;
  int _currentPage = 0;

  // getters
  List<Run> get runs => _runs;
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isLoggedIn => _isLoggedIn;

  /// ✅ UserProvider 변경을 받아서 상태 갱신 + 자동 리로드
  Future<void> updateAuth({
    required bool isLoggedIn,
    required String? userId,
  }) async {
    final changed = (_isLoggedIn != isLoggedIn) || (_userId != userId);
    _isLoggedIn = isLoggedIn;
    _userId = userId;

    if (!changed) return;

    // 로그인/로그아웃 전환 시 히스토리를 자동으로 다시 로드
    await refresh();
  }

  Future<void> refresh() async {
    _runs = [];
    _hasMore = true;
    _currentPage = 0;

    _isInitialLoading = true;
    notifyListeners();

    try {
      if (_isLoggedIn) {
        await _loadSupabaseRuns(reset: true);
      } else {
        await _loadLocalRuns();
      }
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  /// 로그인 상태일 때 스크롤 하단에서 호출
  Future<void> loadMoreIfNeeded() async {
    if (!_isLoggedIn) return;
    if (!_hasMore || _isLoadingMore) return;
    await _loadSupabaseRuns();
  }

  // ────────────────────────────────
  // Local: 최근 3개
  // ────────────────────────────────
  Future<void> _loadLocalRuns() async {
    final results = await (db.select(db.runs)
      ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])
      ..limit(3))
        .get();

    _runs = results;
    _hasMore = false;
  }

  // ────────────────────────────────
  // Supabase: 페이지네이션 (TODO 실제 구현)
  // ────────────────────────────────
  Future<void> _loadSupabaseRuns({bool reset = false}) async {
    if (_isLoadingMore) return;
    if (_userId == null) {
      _hasMore = false;
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      if (reset) {
        _currentPage = 0;
        _runs = [];
        _hasMore = true;
      }

      // ✅ 예시: Supabase에서 가져오기
      final from = _currentPage * _pageSize;
      final to = from + _pageSize - 1;

      final data = await client
          .from('runs')
          .select()
          .eq('user_id', _userId!)
          .order('started_at', ascending: false)
          .range(from, to);

      // ⚠️ 여기서 "Supabase run -> Drift Run"으로 매핑이 필요함
      // 지금 HistoryScreen이 Run(dataClass)로 UI를 그리니까
      // 서버 결과를 Run으로 바꿔야 함.
      //
      // 일단 TODO로 두고, 다음 단계에서 매핑 함수를 만들자.
      final fetched = <Run>[];

      _runs.addAll(fetched);
      _currentPage++;

      if (fetched.length < _pageSize) {
        _hasMore = false;
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
