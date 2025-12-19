import 'package:drift/drift.dart' as drift;
import 'package:runmore/db/app_database.dart';

class RunHomeSummary {
  final double weekKm;
  final double monthKm;
  final List<Run> recentRuns;

  const RunHomeSummary({
    required this.weekKm,
    required this.monthKm,
    required this.recentRuns,
  });
}

class RunHomeSummaryLoader {
  Future<RunHomeSummary> loadFromLocal(AppDatabase db) async {
    final now = DateTime.now();

    // 이번주: 월요일 0시 ~ 지금
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    // 이번달: 1일 0시 ~ 지금
    final monthStart = DateTime(now.year, now.month, 1);

    final weekRuns = await (db.select(db.runs)
      ..where((tbl) => tbl.startedAt.isBiggerOrEqualValue(weekStart)))
        .get();

    final monthRuns = await (db.select(db.runs)
      ..where((tbl) => tbl.startedAt.isBiggerOrEqualValue(monthStart)))
        .get();

    final weekKm = weekRuns.fold<double>(0, (prev, r) => prev + r.distanceMeters) / 1000.0;
    final monthKm =
        monthRuns.fold<double>(0, (prev, r) => prev + r.distanceMeters) / 1000.0;

    final recentRuns = await (db.select(db.runs)
      ..orderBy([
            (tbl) => drift.OrderingTerm(
          expression: tbl.startedAt,
          mode: drift.OrderingMode.desc,
        ),
      ])
      ..limit(3))
        .get();

    return RunHomeSummary(
      weekKm: weekKm,
      monthKm: monthKm,
      recentRuns: recentRuns,
    );
  }
}
