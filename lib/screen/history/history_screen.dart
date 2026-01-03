import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runmore/db/app_database.dart'; // Run dataClass / AppDatabase
import 'package:runmore/provider/history_provider.dart';
import 'package:runmore/provider/user_provider.dart';
import 'package:runmore/screen/history/widget/history_empty_state.dart';
import 'package:runmore/screen/history/widget/login_prompt_card.dart';
import 'package:runmore/screen/history/widget/run_history_card.dart';
import 'package:runmore/screen/login_screen.dart';
import 'package:runmore/screen/run_summary/run_summary_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // runs 테이블 dataClass
  List<Run> _runs = [];

  static const int _pageSize = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final isLoggedIn = context.read<UserProvider>().isLoggedIn;

    try {
      if (!mounted) return;
      if (isLoggedIn) {
        await _loadSupabaseRuns(reset: true);
      } else {
        await _loadLocalRuns();
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    final isLoggedIn = context.read<UserProvider>().isLoggedIn;

    setState(() {
      _isInitialLoading = true;
      _runs = [];
      _hasMore = true;
      _currentPage = 0;
    });

    try {
      if (isLoggedIn) {
        await _loadSupabaseRuns(reset: true);
      } else {
        await _loadLocalRuns();
      }
    } finally {
      if (!mounted) return;
      setState(() => _isInitialLoading = false);
    }
  }


  void _onScroll() {
    final isLoggedIn = context.read<UserProvider>().isLoggedIn;
    if (!isLoggedIn) return; // 비로그인은 페이징 X

    if (!_hasMore || _isLoadingMore) return;

    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      _loadSupabaseRuns();
    }
  }

  // ────────────────────────────────
  // 비로그인 : 로컬 Drift DB에서 최근 기록 가져오기
  // ────────────────────────────────
  Future<void> _loadLocalRuns() async {
    final db = context.read<AppDatabase>();

    // TODO: 실제 AppDatabase에 맞게 메서드 구현
    // 예시) runs 테이블에서 최근 순으로 최대 3개만 가져오기
    final results = await (db.select(db.runs)
      ..orderBy([
            (tbl) => drift.OrderingTerm.desc(tbl.createdAt), // 필드명 맞게 수정
      ])
      ..limit(3))
        .get();

    if (!mounted) return;
    setState(() {
      _runs = results;
      _hasMore = false; // 비로그인은 더 이상 로딩 없음
    });
  }

  // ────────────────────────────────
  // 로그인 : Supabase에서 페이지네이션으로 가져오기 (TODO)
  // ────────────────────────────────
  Future<void> _loadSupabaseRuns({bool reset = false}) async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      if (reset) {
        _currentPage = 0;
        _runs = [];
        _hasMore = true;
      }

      // TODO: Supabase 연동 후 실제 API 호출로 교체
      // 여기서는 일단 더미로 "더 이상 없음" 처리만 해둘게.
      //
      // 예시 흐름:
      // final supabase = Supabase.instance.client;
      // final from = _currentPage * _pageSize;
      // final to = from + _pageSize - 1;
      // final data = await supabase
      //   .from('runs')
      //   .select()
      //   .order('started_at', ascending: false)
      //   .range(from, to);
      //
      // List<Run> fetched = data.map((e) => Run.fromJson(e)).toList();

      final List<Run> fetched = []; // TODO: 실제 Supabase 데이터로 대체

      if (!mounted) return;
      setState(() {
        _runs.addAll(fetched);
        _currentPage++;

        if (fetched.length < _pageSize) {
          _hasMore = false;
        }
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _openRunSummary(Run run) {
    // TODO: run_summary_screen에 맞게 파라미터 수정
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RunSummaryScreen.fromLocalRun(run: run),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final isLoggedIn = context.watch<UserProvider>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('러닝 히스토리')),
      body: RefreshIndicator(
        onRefresh: history.refresh,
        child: history.isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : history.runs.isEmpty
            ? HistoryEmptyState(isLoggedIn: isLoggedIn)
            : NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (!isLoggedIn) return false;
            if (n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
              history.loadMoreIfNeeded();
            }
            return false;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final run in history.runs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RunHistoryCard(
                    run: run,
                    onTap: () { /* summary */ },
                  ),
                ),
              if (!isLoggedIn) const SizedBox(height: 16),
              if (!isLoggedIn) const LoginPromptCard(),
              if (isLoggedIn && history.isLoadingMore) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

