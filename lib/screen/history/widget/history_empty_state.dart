import 'package:flutter/material.dart';

import 'login_prompt_card.dart';

class HistoryEmptyState extends StatelessWidget {
  final bool isLoggedIn;

  const HistoryEmptyState({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
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
        if (!isLoggedIn) const LoginPromptCard(),
      ],
    );
  }
}
