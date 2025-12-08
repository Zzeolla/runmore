import 'package:supabase_flutter/supabase_flutter.dart';

/// 특정 요청 동안만 REST 헤더를 임시로 붙였다가 원복한다.
Future<T> withRestHeaders<T>(
    Map<String, String> headers,
    Future<T> Function() action,
    ) async {
  final rest = Supabase.instance.client.rest;

  // 기존 헤더 백업
  final previous = <String, String?>{};
  for (final entry in headers.entries) {
    previous[entry.key] = rest.headers[entry.key];
    rest.headers[entry.key] = entry.value;
  }

  try {
    return await action();
  } finally {
    // 원복
    for (final key in headers.keys) {
      final prev = previous[key];
      if (prev == null) {
        rest.headers.remove(key);
      } else {
        rest.headers[key] = prev;
      }
    }
  }
}
