import 'package:drift/drift.dart';

class Runs extends Table {
  // uuid string
  TextColumn get id => text()();

  // 러닝 시작/종료 시각
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();

  // 기본 통계
  RealColumn get distanceMeters => real()();      // 총 거리 (m)
  IntColumn get elapsedSeconds => integer()();    // 실제 달린 시간(초)
  RealColumn get avgSpeedMps => real()();         // 평균 속도 (m/s)

  // 선택: 칼로리
  IntColumn get calories => integer().nullable()();
  IntColumn get avgHr => integer().nullable()();
  IntColumn get avgCadence => integer().nullable()();


  // 경로: [{ "lat": 37.5, "lng": 126.9 }, ...] JSON 문자열
  TextColumn get pathJson => text()();

  // 구간 페이스: PaceSegment 리스트 JSON
  TextColumn get segmentsJson => text()();

  // 생성 시각
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}


class RunningTicks extends Table {
  IntColumn get seq => integer().autoIncrement()(); // 순서/정렬 편함
  DateTimeColumn get ts => dateTime()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  RealColumn get speedMps => real().nullable()();
  IntColumn get hr => integer().nullable()();        // heart rate (bpm)
  IntColumn get cadence => integer().nullable()();   // cadence (spm)
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
}

class RunningState extends Table {
  // 항상 1행만 유지 (PK=1)
  IntColumn get id => integer().withDefault(const Constant(1))();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastTs => dateTime().nullable()();

  RealColumn get distanceMeters => real()();
  IntColumn get elapsedSeconds => integer()();
  RealColumn get avgSpeedMps => real()();

  BoolColumn get isPaused => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}