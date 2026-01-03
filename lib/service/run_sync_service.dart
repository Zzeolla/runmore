import 'dart:convert';

import 'package:runmore/db/app_database.dart';
import 'package:runmore/model/run_record.dart';
import 'package:runmore/repository/local_run_repository.dart';
import 'package:runmore/repository/supabase_run_repository.dart';

class RunSyncService {
  final LocalRunRepository localRepo;
  final SupabaseRunRepository remoteRepo;

  RunSyncService({
    required AppDatabase db,
    SupabaseRunRepository? remoteRepo,
  })  : localRepo = LocalRunRepository(db),
        remoteRepo = remoteRepo ?? SupabaseRunRepository();

  /// 로그인 직후 1회 호출
  Future<int> syncLocalRunsToSupabase({
    required String userId,
  }) async {
    // 1) 로컬 runs 전부 가져오기 (최대 3개 정책이면 로컬에 이미 3개 이하)
    final localRuns = await localRepo.getAllRuns();
    if (localRuns.isEmpty) return 0;

    final localIds = localRuns.map((r) => r.id).toList();

    // 2) Supabase에 이미 존재하는 id 조회
    final existingIds = await remoteRepo.fetchExistingIds(localIds);

    int uploadedCount = 0;

    // 3) 없는 것만 업로드
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
        avgHr: r.avgHr,
        avgCadence: r.avgCadence,
        pathJson: (jsonDecode(r.pathJson) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        segmentsJson: (jsonDecode(r.segmentsJson) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        liveRoomId: null,
        createdAt: r.createdAt,
      );

      await remoteRepo.upsertRun(record);
      uploadedCount++;
    }

    return uploadedCount;
  }
}
