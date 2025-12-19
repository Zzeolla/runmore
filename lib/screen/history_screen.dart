import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runmore/db/app_database.dart'; // Run dataClass / AppDatabase
import 'package:runmore/provider/user_provider.dart';
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
    _isInitialLoading = false;
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

    if (isLoggedIn) {
      await _loadSupabaseRuns(reset: true);
    } else {
      await _loadLocalRuns();
    }

    if (!mounted) return;
    setState(() {
      _isInitialLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserProvider>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('러닝 히스토리'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : _runs.isEmpty
            ? _buildEmptyState(isLoggedIn)
            : ListView(
          controller: _scrollController,
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            ..._runs.map(
                  (run) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RunHistoryCard(
                  run: run,
                  onTap: () {
                    // TODO: run_summary_screen에 맞게 파라미터 수정
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RunSummaryScreen.fromLocalRun(run: run), // 예시
                      ),
                    );
                  },
                ),
              ),
            ),
            if (!isLoggedIn) const SizedBox(height: 16),
            if (!isLoggedIn) const _LoginPromptCard(),
            if (isLoggedIn && _isLoadingMore) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isLoggedIn) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      children: [
        const Icon(Icons.directions_run, size: 72, color: Colors.grey),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '아직 저장된 러닝 기록이 없어요.\n\n첫 러닝을 시작해 볼까요',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        if (!isLoggedIn) const _LoginPromptCard(),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// 예쁜 러닝 기록 카드
/// run.* 필드명은 실제 runs 테이블 구조에 맞게 수정해서 사용
/// ─────────────────────────────────────────────────────────
class _RunHistoryCard extends StatelessWidget {
  final Run run;
  final VoidCallback? onTap;

  const _RunHistoryCard({
    required this.run,
    this.onTap,
  });

  // 날짜 포맷
  String _formatDate(DateTime dt) {
    // TODO: intl 패키지 쓰면 더 깔끔하지만 우선 간단하게
    final weekdayKo = ['월', '화', '수', '목', '금', '토', '일'][dt.weekday - 1];
    return "${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ($weekdayKo)";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _formatDistance(double meters) {
    final km = meters / 1000.0;
    return km.toStringAsFixed(2);
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    } else {
      return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
  }

  String _formatPace(double meters, int seconds) {
    if (meters <= 0 || seconds <= 0) return '--';
    final km = meters / 1000.0;
    final paceSec = (seconds / km).round(); // 초 / km
    final m = paceSec ~/ 60;
    final s = paceSec % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 아래 필드명은 실제 Run dataClass에 맞게 수정
    final startedAt = run.startedAt; // DateTime
    final distanceMeters = run.distanceMeters; // double
    final elapsedSeconds = run.elapsedSeconds; // int

    final dateStr = _formatDate(startedAt);
    final timeStr = _formatTime(startedAt);
    final distanceStr = _formatDistance(distanceMeters);
    final durationStr = _formatDuration(elapsedSeconds);
    final paceStr = _formatPace(distanceMeters, elapsedSeconds);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 + 거리
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 날짜/시간
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 거리
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      distanceStr,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'km',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 시간 / 평균 페이스
            Row(
              children: [
                _StatChip(
                  icon: Icons.timer_outlined,
                  label: '시간',
                  value: durationStr,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.directions_run,
                  label: '평균 페이스',
                  value: paceStr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withOpacity(0.08);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.9)),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 비로그인일 때 리스트 아래에 깔리는 안내 카드
class _LoginPromptCard extends StatelessWidget {
  const _LoginPromptCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_open_rounded, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '3개 이상의 러닝 기록을 쌓으려면 로그인이 필요합니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
    ),
    ),
    const SizedBox(width: 8),
    TextButton(
    onPressed: () async {
    final result = await Navigator.of(context).push(
    MaterialPageRoute(
    builder: (_) => const LoginScreen(),
    fullscreenDialog: true, // iOS 느낌 좋음
    ),
    );
    if (result == true) {
    // TODO: 추후 검토해보기
    // 로그인 성공 후 하고 싶은 동작
    // 예: provider reload, API 재호출, UI 갱신
              }
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}
