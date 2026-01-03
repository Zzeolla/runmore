import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/provider/run_provider.dart';
import 'package:runmore/repository/local_run_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ─────────────────────────────────
  // 1) 현재 Supabase 세션 확인
  // 2) 로그인 여부에 따라 다음 화면으로 이동
  // ─────────────────────────────────
  Future<void> _checkAuthAndNavigate() async {
    // 살짝 로고가 보이도록 500ms 정도 딜레이 (선택사항)
    await Future.delayed(const Duration(milliseconds: 500));

    final isServiceRunning = await FlutterForegroundTask.isRunningService;

    if (!mounted) return;

    if (isServiceRunning) {
      final run = context.read<RunProvider>();
      // TODO: run.restoreFromRunningService 함수는 정비 필요, restoreFromRunningDb는 지워도 될라나?
      await run.restoreFromRunningService();
    } else {
      final db = context.read<AppDatabase>();
      final localRepo = LocalRunRepository(db);
      await localRepo.clearTempRun();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/main');
  }

  // ─────────────────────────────────
  // 화면 UI (로고 + 로딩 스피너)
  // ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cream White
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Image.asset(
              'assets/icon/splash_icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              '런모아',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '', // TODO : 설명 문구 추가하기
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9A9A9A),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
