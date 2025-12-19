import 'dart:convert';

import 'package:runmore/db/app_database.dart';
import 'package:runmore/model/run_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RunSyncService {
  final AppDatabase db;
  final SupabaseClient client;

  RunSyncService({
    required this.db,
    SupabaseClient? client,
  }) : client = client ?? Supabase.instance.client;

  /// 로그인 직후 1회 호출
  Future<int> syncLocalRunsToSupabase({
    required String userId,
  }) async {
    // 1) 로컬 runs 전부 가져오기 (최대 3개)
    final localRuns = await db.select(db.runs).get();
    if (localRuns.isEmpty) return 0;

    final localIds = localRuns.map((r) => r.id).toList();

    // 2) Supabase에 이미 존재하는 run id 조회
    final existing = await client
        .from('runs')
        .select('id')
        .inFilter('id', localIds);

    final existingIds = (existing as List)
        .map((e) => e['id'] as String)
        .toSet();

    int uploadedCount = 0;

    // 3) 없는 것만 RunRecord로 변환 후 업로드
    for (final r in localRuns) {
      if (existingIds.contains(r.id)) continue;

      final record = RunRecord(
        id: r.id,
        userId: userId,
        startedAt: r.startedAt,
        endedAt: r.endedAt,
        distanceM: r.distanceMeters,
        elapsedS: r.elapsedSeconds,
        avgSpeedMps: r.avgSpeedMps,
        calories: r.calories,
        pathJson: jsonDecode(r.pathJson),
        segmentsJson: jsonDecode(r.segmentsJson),
        liveRoomId: null,
        createdAt: r.createdAt,
      );

      await client.from('runs').insert(record.toJson());
      uploadedCount++;
    }

    return uploadedCount;
  }
}
