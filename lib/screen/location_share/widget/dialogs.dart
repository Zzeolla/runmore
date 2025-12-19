import 'package:flutter/material.dart';

Future<String?> showShareCodeDialog(BuildContext context) {
  final controller = TextEditingController();
  final canSubmit = ValueNotifier(false);

  controller.addListener(() {
    final v = controller.text.trim();
    canSubmit.value = v.length >= 6; // 너 코드 길이에 맞춰(8이면 8)
  });

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (ctx) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7FB),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('공유 코드 입력',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: '예: a1b2c3d4',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) {
                    // ✅ 공백 제거 + 소문자 통일(원하면 uppercase로 바꿔도 됨)
                    final cleaned = v.replaceAll(' ', '').toLowerCase();
                    if (cleaned != v) {
                      controller.value = controller.value.copyWith(
                        text: cleaned,
                        selection: TextSelection.collapsed(offset: cleaned.length),
                      );
                    }
                  },
                  onSubmitted: (_) {
                    final code = controller.text.trim().replaceAll(' ', '').toLowerCase();
                    if (code.isNotEmpty) Navigator.pop(ctx, code);
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: canSubmit,
                      builder: (_, ok, __) {
                        return FilledButton(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: ok
                              ? () {
                            final code = controller.text.trim().replaceAll(' ', '').toLowerCase();
                            Navigator.pop(ctx, code);
                          }
                              : null,
                          child: const Text('확인'),
                        );
                      },
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

Future<String?> showCreateRoomDialog(BuildContext context) {
  final controller = TextEditingController(text: '런모아 라이브');
  final canSubmit = ValueNotifier(true);

  controller.addListener(() {
    canSubmit.value = controller.text.trim().isNotEmpty;
  });

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (ctx) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7FB),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('방 만들기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: '예: 서울숲 저녁런',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) {
                    final title = controller.text.trim();
                    if (title.isNotEmpty) Navigator.pop(ctx, title);
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: canSubmit,
                      builder: (_, ok, __) {
                        return FilledButton(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: ok ? () => Navigator.pop(ctx, controller.text.trim()) : null,
                          child: const Text('생성'),
                        );
                      },
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
