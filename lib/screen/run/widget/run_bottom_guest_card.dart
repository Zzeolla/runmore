import 'package:flutter/material.dart';
import 'package:runmore/screen/login_screen.dart';

class RunBottomGuestCard extends StatelessWidget {
  const RunBottomGuestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 40,
            right: 40,
            bottom: 16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text('🔒', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '로그인하면 이번주/이번달 누적 거리와 최근 러닝 기록을 한 눈에 볼 수 있어요.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                    if (result == true) {
                      // TODO: 추후 검토해보기
                      // 로그인 성공 후 하고 싶은 동작
                      // 예: provider reload, API 재호출, UI 갱신
                    }
                  },
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
