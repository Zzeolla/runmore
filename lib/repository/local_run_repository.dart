import 'package:drift/drift.dart' as drift;
import 'package:runmore/db/app_database.dart';

class LocalRunRepository {
  final AppDatabase db;
  LocalRunRepository(this.db);

  // TEMP
  Future<void> upsertRunningState({
    required DateTime startedAt,
    DateTime? lastTs,
    required double distanceMeters,
    required int elapsedSeconds,
    required double avgSpeedMps,
    required bool isPaused,
  }) async {
    await db.into(db.runningState).insertOnConflictUpdate(
      RunningStateCompanion.insert(
        id: const drift.Value(1),
        startedAt: startedAt,
        lastTs: drift.Value(lastTs),
        distanceMeters: distanceMeters,
        elapsedSeconds: elapsedSeconds,
        avgSpeedMps: avgSpeedMps,
        isPaused: isPaused,
      ),
    );
  }

  Future<RunningStateData?> getRunningState() {
    return (db.select(db.runningState)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
  }

  Future<void> insertRunningTick({
    required DateTime ts,
    required double lat,
    required double lng,
    double? altitude,
    double? accuracy,
    double? speedMps,
    int? hr,
    int? cadence,
    required bool isPaused,
  }) async {
    await db.into(db.runningTicks).insert(
      RunningTicksCompanion.insert(
        ts: ts,
        lat: lat,
        lng: lng,
        altitude: drift.Value(altitude),
        accuracy: drift.Value(accuracy),
        speedMps: drift.Value(speedMps),
        hr: drift.Value(hr),
        cadence: drift.Value(cadence),
        isPaused: drift.Value(isPaused),
      ),
    );
  }

  Future<List<RunningTick>> getRunningTicks({bool includePaused = true}) {
    final q = db.select(db.runningTicks)
      ..orderBy([(t) => drift.OrderingTerm(expression: t.seq)]);
    if (!includePaused) q.where((t) => t.isPaused.equals(false));
    return q.get();
  }

  Future<void> clearTempRun() async {
    await db.batch((b) {
      b.deleteAll(db.runningTicks);
      b.deleteAll(db.runningState);
    });
  }

  // FINAL
  Future<void> saveRunWithLimit(RunsCompanion run, {int maxKeep = 3}) async {
    // 오래된 createdAt부터 정렬해서 maxKeep-1개 남기고 지움
    final existing = await (db.select(db.runs)
      ..orderBy([
            (t) => drift.OrderingTerm(
          expression: t.createdAt,
          mode: drift.OrderingMode.asc,
        ),
      ]))
        .get();

    // 이미 maxKeep 이상이면 초과분 만큼 삭제
    final overflow = (existing.length + 1) - maxKeep; // +1은 이번에 추가될 1개
    if (overflow > 0) {
      for (int i = 0; i < overflow; i++) {
        await (db.delete(db.runs)..where((t) => t.id.equals(existing[i].id))).go();
      }
    }

    await db.into(db.runs).insert(run);
  }


  Future<void> upsertRun(RunsCompanion run) async {
    await db.into(db.runs).insertOnConflictUpdate(run);
  }

  Future<List<Run>> getAllRuns() {
    final q = db.select(db.runs)
      ..orderBy([
            (t) => drift.OrderingTerm(
          expression: t.startedAt,
          mode: drift.OrderingMode.desc,
        ),
      ]);
    return q.get();
  }

  Future<void> deleteRunById(String id) async {
    await (db.delete(db.runs)..where((t) => t.id.equals(id))).go();
  }
}
