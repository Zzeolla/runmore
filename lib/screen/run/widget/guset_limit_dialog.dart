import 'package:flutter/material.dart';
import 'package:runmore/screen/login_screen.dart';

Future<void> showGuestLimitDialog(BuildContext context) {
  const accent = Color(0xFF4CAF81);

  return showDialog<void>(
    context: context,
    barrierDismissible: true, // 바깥 터치로 닫기 허용
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 12),
                color: Colors.black.withOpacity(0.12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '👟',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 타이틀
              const Text(
                '게스트 기록은 3개까지만 저장돼요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              // 내용
              const Text(
                '로그인하지 않은 상태에서는 러닝 기록을\n'
                    '최대 3개까지만 저장할 수 있어요.\n\n'
                    '기록을 계속 쌓고, 기기를 바꿔도\n'
                    '안전하게 보관하려면 로그인이 필요해요.\n\n'
                    '기록이 3개를 초과했다면\n'
                    '가장 오래된 기록은 자동 삭제됩니다.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '로그인하면 기록을 무제한으로 보관할 수 있어요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9A9A9A),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // 버튼 2개 (가로로 꽉 채우기)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: const Color(0xFF666666),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        '나중에 할게요',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
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
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        '로그인하기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
