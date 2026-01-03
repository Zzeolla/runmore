import 'package:flutter/material.dart';
import 'package:runmore/screen/login_screen.dart';

class LoginPromptCard extends StatelessWidget {
  const LoginPromptCard({super.key});

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
                  fullscreenDialog: true,
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
