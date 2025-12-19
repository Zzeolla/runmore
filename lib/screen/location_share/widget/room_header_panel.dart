import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:runmore/provider/live_share_provider.dart';
import 'package:runmore/provider/user_provider.dart';
import 'package:runmore/screen/location_share/widget/dialogs.dart';
import 'package:runmore/screen/login_screen.dart';
import 'package:runmore/widget/snackbar.dart';

class RoomHeaderPanel extends StatelessWidget {
  const RoomHeaderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final live = context.watch<LiveShareProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: live.isInRoom
          ? _InRoomHeader(live: live)
          : _NoRoomHeader(live: live),
    );
  }
}

class _NoRoomHeader extends StatelessWidget {
  final LiveShareProvider live;
  const _NoRoomHeader({required this.live});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () async {
              final isLoggedIn = context.read<UserProvider>().isLoggedIn;
              if (!isLoggedIn) {
                showRunSnackBar(
                  context,
                  message: '방 생성은 로그인 후 가능합니다.',
                  icon: '🔒',
                  actionLabel: '로그인',
                  onAction: () async {
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
                );
                return;
              }
              final title = await showCreateRoomDialog(context);
              if (title == null || title.trim().isEmpty) return;

              await live.createAndJoinRoom(title: title.trim());

              showRunSnackBar(
                context,
                message: '방이 생성되었습니다. 공유코드를 전달하세요!',
                icon: '✅',
              );

              await Clipboard.setData(ClipboardData(text: live.room!.shareCode));
            },
            child: const Text('방 생성'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.meeting_room_outlined, size: 18),
            onPressed: () async {
              final code = await showShareCodeDialog(context);
              if (code == null || code.trim().isEmpty) return;
              await live.joinByShareCode(code.trim());
            },
            label: const Text('방 참가'),
          ),
        ),
      ],
    );
  }
}

class _InRoomHeader extends StatelessWidget {
  final LiveShareProvider live;
  const _InRoomHeader({required this.live});

  @override
  Widget build(BuildContext context) {
    final room = live.room!;
    final runnerCount = live.runners.length;

    final now = DateTime.now();
    final remaining = room.expiredAt.difference(now);
    final remainingText = remaining.isNegative
        ? '만료됨'
        : '${remaining.inMinutes}분 남음';

    return Row(
      children: [
        // 왼쪽: 방 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '러너 $runnerCount명',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // 오른쪽: 남은 시간 + 버튼들
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              remainingText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!live.isRunner)
                  FilledButton.tonal(
                    onPressed: () async {
                      // // TODO: 닉네임 입력 다이얼로그 띄워도 됨
                      // await live.joinAsRunner(
                      //   displayName: '나', // 나중에 nickname으로 교체
                      // );
                    },
                    child: const Text('러너로 참여'),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      '러너 모드',
                      style: TextStyle(
                        color: Colors.lightGreenAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),

                if (live.isOwner)
                  TextButton(
                    onPressed: () async {
                      try {
                        await live.endRoom();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('방이 종료되었습니다.')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    child: const Text(
                      '방 종료',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
