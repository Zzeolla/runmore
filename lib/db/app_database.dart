// lib/db/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'run_db.dart';

part 'app_database.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

@DriftDatabase(tables: [Runs, RunningTicks, RunningState])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(runningTicks);
        await m.createTable(runningState);
      }
      if (from < 3) {
        await m.addColumn(runs, runs.avgHr);
        await m.addColumn(runs, runs.avgCadence);
      }
      if (from < 4) {
        await m.addColumn(runningTicks, runningTicks.hr);
        await m.addColumn(runningTicks, runningTicks.cadence);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'runmore.db'));
    return NativeDatabase.createInBackground(file);
  });
}
