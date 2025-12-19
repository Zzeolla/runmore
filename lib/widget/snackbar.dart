import 'package:flutter/material.dart';

void showRunSnackBar(
    BuildContext context, {
      required String message,
      String icon = '🏃‍♂️',
      Color backgroundColor = const Color(0xFF000000), // 검정 반투명
      Duration duration = const Duration(seconds: 3),
      String? actionLabel,
      VoidCallback? onAction,
    }) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.clearSnackBars(); // ✅ 큐까지 정리
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 8,
      backgroundColor: backgroundColor.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      duration: duration,
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label : actionLabel,
              onPressed: () {
                messenger.clearSnackBars();
                onAction();
              },
              textColor: Colors.white,
            )
          : null,
      content: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
