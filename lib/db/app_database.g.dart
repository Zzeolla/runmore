// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RunsTable extends Runs with TableInfo<$RunsTable, Run> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta(
    'elapsedSeconds',
  );
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgSpeedMpsMeta = const VerificationMeta(
    'avgSpeedMps',
  );
  @override
  late final GeneratedColumn<double> avgSpeedMps = GeneratedColumn<double>(
    'avg_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathJsonMeta = const VerificationMeta(
    'pathJson',
  );
  @override
  late final GeneratedColumn<String> pathJson = GeneratedColumn<String>(
    'path_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentsJsonMeta = const VerificationMeta(
    'segmentsJson',
  );
  @override
  late final GeneratedColumn<String> segmentsJson = GeneratedColumn<String>(
    'segments_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    distanceMeters,
    elapsedSeconds,
    avgSpeedMps,
    calories,
    pathJson,
    segmentsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Run> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(
          data['elapsed_seconds']!,
          _elapsedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedSecondsMeta);
    }
    if (data.containsKey('avg_speed_mps')) {
      context.handle(
        _avgSpeedMpsMeta,
        avgSpeedMps.isAcceptableOrUnknown(
          data['avg_speed_mps']!,
          _avgSpeedMpsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgSpeedMpsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('path_json')) {
      context.handle(
        _pathJsonMeta,
        pathJson.isAcceptableOrUnknown(data['path_json']!, _pathJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_pathJsonMeta);
    }
    if (data.containsKey('segments_json')) {
      context.handle(
        _segmentsJsonMeta,
        segmentsJson.isAcceptableOrUnknown(
          data['segments_json']!,
          _segmentsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Run map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Run(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      startedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}started_at'],
          )!,
      endedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}ended_at'],
          )!,
      distanceMeters:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}distance_meters'],
          )!,
      elapsedSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}elapsed_seconds'],
          )!,
      avgSpeedMps:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}avg_speed_mps'],
          )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      ),
      pathJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}path_json'],
          )!,
      segmentsJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}segments_json'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }
}

class Run extends DataClass implements Insertable<Run> {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceMeters;
  final int elapsedSeconds;
  final double avgSpeedMps;
  final int? calories;
  final String pathJson;
  final String segmentsJson;
  final DateTime createdAt;
  const Run({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.distanceMeters,
    required this.elapsedSeconds,
    required this.avgSpeedMps,
    this.calories,
    required this.pathJson,
    required this.segmentsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    map['avg_speed_mps'] = Variable<double>(avgSpeedMps);
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<int>(calories);
    }
    map['path_json'] = Variable<String>(pathJson);
    map['segments_json'] = Variable<String>(segmentsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      distanceMeters: Value(distanceMeters),
      elapsedSeconds: Value(elapsedSeconds),
      avgSpeedMps: Value(avgSpeedMps),
      calories:
          calories == null && nullToAbsent
              ? const Value.absent()
              : Value(calories),
      pathJson: Value(pathJson),
      segmentsJson: Value(segmentsJson),
      createdAt: Value(createdAt),
    );
  }

  factory Run.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Run(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      avgSpeedMps: serializer.fromJson<double>(json['avgSpeedMps']),
      calories: serializer.fromJson<int?>(json['calories']),
      pathJson: serializer.fromJson<String>(json['pathJson']),
      segmentsJson: serializer.fromJson<String>(json['segmentsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'avgSpeedMps': serializer.toJson<double>(avgSpeedMps),
      'calories': serializer.toJson<int?>(calories),
      'pathJson': serializer.toJson<String>(pathJson),
      'segmentsJson': serializer.toJson<String>(segmentsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Run copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    double? distanceMeters,
    int? elapsedSeconds,
    double? avgSpeedMps,
    Value<int?> calories = const Value.absent(),
    String? pathJson,
    String? segmentsJson,
    DateTime? createdAt,
  }) => Run(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
    calories: calories.present ? calories.value : this.calories,
    pathJson: pathJson ?? this.pathJson,
    segmentsJson: segmentsJson ?? this.segmentsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  Run copyWithCompanion(RunsCompanion data) {
    return Run(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      distanceMeters:
          data.distanceMeters.present
              ? data.distanceMeters.value
              : this.distanceMeters,
      elapsedSeconds:
          data.elapsedSeconds.present
              ? data.elapsedSeconds.value
              : this.elapsedSeconds,
      avgSpeedMps:
          data.avgSpeedMps.present ? data.avgSpeedMps.value : this.avgSpeedMps,
      calories: data.calories.present ? data.calories.value : this.calories,
      pathJson: data.pathJson.present ? data.pathJson.value : this.pathJson,
      segmentsJson:
          data.segmentsJson.present
              ? data.segmentsJson.value
              : this.segmentsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Run(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('calories: $calories, ')
          ..write('pathJson: $pathJson, ')
          ..write('segmentsJson: $segmentsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    distanceMeters,
    elapsedSeconds,
    avgSpeedMps,
    calories,
    pathJson,
    segmentsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Run &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.distanceMeters == this.distanceMeters &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.avgSpeedMps == this.avgSpeedMps &&
          other.calories == this.calories &&
          other.pathJson == this.pathJson &&
          other.segmentsJson == this.segmentsJson &&
          other.createdAt == this.createdAt);
}

class RunsCompanion extends UpdateCompanion<Run> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<double> distanceMeters;
  final Value<int> elapsedSeconds;
  final Value<double> avgSpeedMps;
  final Value<int?> calories;
  final Value<String> pathJson;
  final Value<String> segmentsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.calories = const Value.absent(),
    this.pathJson = const Value.absent(),
    this.segmentsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required DateTime startedAt,
    required DateTime endedAt,
    required double distanceMeters,
    required int elapsedSeconds,
    required double avgSpeedMps,
    this.calories = const Value.absent(),
    required String pathJson,
    required String segmentsJson,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       distanceMeters = Value(distanceMeters),
       elapsedSeconds = Value(elapsedSeconds),
       avgSpeedMps = Value(avgSpeedMps),
       pathJson = Value(pathJson),
       segmentsJson = Value(segmentsJson);
  static Insertable<Run> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? distanceMeters,
    Expression<int>? elapsedSeconds,
    Expression<double>? avgSpeedMps,
    Expression<int>? calories,
    Expression<String>? pathJson,
    Expression<String>? segmentsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (avgSpeedMps != null) 'avg_speed_mps': avgSpeedMps,
      if (calories != null) 'calories': calories,
      if (pathJson != null) 'path_json': pathJson,
      if (segmentsJson != null) 'segments_json': segmentsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<double>? distanceMeters,
    Value<int>? elapsedSeconds,
    Value<double>? avgSpeedMps,
    Value<int?>? calories,
    Value<String>? pathJson,
    Value<String>? segmentsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
      calories: calories ?? this.calories,
      pathJson: pathJson ?? this.pathJson,
      segmentsJson: segmentsJson ?? this.segmentsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (avgSpeedMps.present) {
      map['avg_speed_mps'] = Variable<double>(avgSpeedMps.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (pathJson.present) {
      map['path_json'] = Variable<String>(pathJson.value);
    }
    if (segmentsJson.present) {
      map['segments_json'] = Variable<String>(segmentsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('calories: $calories, ')
          ..write('pathJson: $pathJson, ')
          ..write('segmentsJson: $segmentsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunningTicksTable extends RunningTicks
    with TableInfo<$RunningTicksTable, RunningTick> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunningTicksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    ts,
    lat,
    lng,
    altitude,
    accuracy,
    speedMps,
    isPaused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'running_ticks';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunningTick> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  RunningTick map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunningTick(
      seq:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}seq'],
          )!,
      ts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}ts'],
          )!,
      lat:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}lat'],
          )!,
      lng:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}lng'],
          )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      speedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_mps'],
      ),
      isPaused:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_paused'],
          )!,
    );
  }

  @override
  $RunningTicksTable createAlias(String alias) {
    return $RunningTicksTable(attachedDatabase, alias);
  }
}

class RunningTick extends DataClass implements Insertable<RunningTick> {
  final int seq;
  final DateTime ts;
  final double lat;
  final double lng;
  final double? altitude;
  final double? accuracy;
  final double? speedMps;
  final bool isPaused;
  const RunningTick({
    required this.seq,
    required this.ts,
    required this.lat,
    required this.lng,
    this.altitude,
    this.accuracy,
    this.speedMps,
    required this.isPaused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['ts'] = Variable<DateTime>(ts);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || speedMps != null) {
      map['speed_mps'] = Variable<double>(speedMps);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    return map;
  }

  RunningTicksCompanion toCompanion(bool nullToAbsent) {
    return RunningTicksCompanion(
      seq: Value(seq),
      ts: Value(ts),
      lat: Value(lat),
      lng: Value(lng),
      altitude:
          altitude == null && nullToAbsent
              ? const Value.absent()
              : Value(altitude),
      accuracy:
          accuracy == null && nullToAbsent
              ? const Value.absent()
              : Value(accuracy),
      speedMps:
          speedMps == null && nullToAbsent
              ? const Value.absent()
              : Value(speedMps),
      isPaused: Value(isPaused),
    );
  }

  factory RunningTick.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunningTick(
      seq: serializer.fromJson<int>(json['seq']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      speedMps: serializer.fromJson<double?>(json['speedMps']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'ts': serializer.toJson<DateTime>(ts),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'altitude': serializer.toJson<double?>(altitude),
      'accuracy': serializer.toJson<double?>(accuracy),
      'speedMps': serializer.toJson<double?>(speedMps),
      'isPaused': serializer.toJson<bool>(isPaused),
    };
  }

  RunningTick copyWith({
    int? seq,
    DateTime? ts,
    double? lat,
    double? lng,
    Value<double?> altitude = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    Value<double?> speedMps = const Value.absent(),
    bool? isPaused,
  }) => RunningTick(
    seq: seq ?? this.seq,
    ts: ts ?? this.ts,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    altitude: altitude.present ? altitude.value : this.altitude,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    speedMps: speedMps.present ? speedMps.value : this.speedMps,
    isPaused: isPaused ?? this.isPaused,
  );
  RunningTick copyWithCompanion(RunningTicksCompanion data) {
    return RunningTick(
      seq: data.seq.present ? data.seq.value : this.seq,
      ts: data.ts.present ? data.ts.value : this.ts,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunningTick(')
          ..write('seq: $seq, ')
          ..write('ts: $ts, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speedMps: $speedMps, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(seq, ts, lat, lng, altitude, accuracy, speedMps, isPaused);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunningTick &&
          other.seq == this.seq &&
          other.ts == this.ts &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.altitude == this.altitude &&
          other.accuracy == this.accuracy &&
          other.speedMps == this.speedMps &&
          other.isPaused == this.isPaused);
}

class RunningTicksCompanion extends UpdateCompanion<RunningTick> {
  final Value<int> seq;
  final Value<DateTime> ts;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double?> altitude;
  final Value<double?> accuracy;
  final Value<double?> speedMps;
  final Value<bool> isPaused;
  const RunningTicksCompanion({
    this.seq = const Value.absent(),
    this.ts = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.isPaused = const Value.absent(),
  });
  RunningTicksCompanion.insert({
    this.seq = const Value.absent(),
    required DateTime ts,
    required double lat,
    required double lng,
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.isPaused = const Value.absent(),
  }) : ts = Value(ts),
       lat = Value(lat),
       lng = Value(lng);
  static Insertable<RunningTick> custom({
    Expression<int>? seq,
    Expression<DateTime>? ts,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? altitude,
    Expression<double>? accuracy,
    Expression<double>? speedMps,
    Expression<bool>? isPaused,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (ts != null) 'ts': ts,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speedMps != null) 'speed_mps': speedMps,
      if (isPaused != null) 'is_paused': isPaused,
    });
  }

  RunningTicksCompanion copyWith({
    Value<int>? seq,
    Value<DateTime>? ts,
    Value<double>? lat,
    Value<double>? lng,
    Value<double?>? altitude,
    Value<double?>? accuracy,
    Value<double?>? speedMps,
    Value<bool>? isPaused,
  }) {
    return RunningTicksCompanion(
      seq: seq ?? this.seq,
      ts: ts ?? this.ts,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speedMps: speedMps ?? this.speedMps,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunningTicksCompanion(')
          ..write('seq: $seq, ')
          ..write('ts: $ts, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speedMps: $speedMps, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }
}

class $RunningStateTable extends RunningState
    with TableInfo<$RunningStateTable, RunningStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunningStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastTsMeta = const VerificationMeta('lastTs');
  @override
  late final GeneratedColumn<DateTime> lastTs = GeneratedColumn<DateTime>(
    'last_ts',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta(
    'elapsedSeconds',
  );
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgSpeedMpsMeta = const VerificationMeta(
    'avgSpeedMps',
  );
  @override
  late final GeneratedColumn<double> avgSpeedMps = GeneratedColumn<double>(
    'avg_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    lastTs,
    distanceMeters,
    elapsedSeconds,
    avgSpeedMps,
    isPaused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'running_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunningStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_ts')) {
      context.handle(
        _lastTsMeta,
        lastTs.isAcceptableOrUnknown(data['last_ts']!, _lastTsMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(
          data['elapsed_seconds']!,
          _elapsedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedSecondsMeta);
    }
    if (data.containsKey('avg_speed_mps')) {
      context.handle(
        _avgSpeedMpsMeta,
        avgSpeedMps.isAcceptableOrUnknown(
          data['avg_speed_mps']!,
          _avgSpeedMpsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgSpeedMpsMeta);
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    } else if (isInserting) {
      context.missing(_isPausedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunningStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunningStateData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      startedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}started_at'],
          )!,
      lastTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_ts'],
      ),
      distanceMeters:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}distance_meters'],
          )!,
      elapsedSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}elapsed_seconds'],
          )!,
      avgSpeedMps:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}avg_speed_mps'],
          )!,
      isPaused:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_paused'],
          )!,
    );
  }

  @override
  $RunningStateTable createAlias(String alias) {
    return $RunningStateTable(attachedDatabase, alias);
  }
}

class RunningStateData extends DataClass
    implements Insertable<RunningStateData> {
  final int id;
  final DateTime startedAt;
  final DateTime? lastTs;
  final double distanceMeters;
  final int elapsedSeconds;
  final double avgSpeedMps;
  final bool isPaused;
  const RunningStateData({
    required this.id,
    required this.startedAt,
    this.lastTs,
    required this.distanceMeters,
    required this.elapsedSeconds,
    required this.avgSpeedMps,
    required this.isPaused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || lastTs != null) {
      map['last_ts'] = Variable<DateTime>(lastTs);
    }
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    map['avg_speed_mps'] = Variable<double>(avgSpeedMps);
    map['is_paused'] = Variable<bool>(isPaused);
    return map;
  }

  RunningStateCompanion toCompanion(bool nullToAbsent) {
    return RunningStateCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      lastTs:
          lastTs == null && nullToAbsent ? const Value.absent() : Value(lastTs),
      distanceMeters: Value(distanceMeters),
      elapsedSeconds: Value(elapsedSeconds),
      avgSpeedMps: Value(avgSpeedMps),
      isPaused: Value(isPaused),
    );
  }

  factory RunningStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunningStateData(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      lastTs: serializer.fromJson<DateTime?>(json['lastTs']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      avgSpeedMps: serializer.fromJson<double>(json['avgSpeedMps']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'lastTs': serializer.toJson<DateTime?>(lastTs),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'avgSpeedMps': serializer.toJson<double>(avgSpeedMps),
      'isPaused': serializer.toJson<bool>(isPaused),
    };
  }

  RunningStateData copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> lastTs = const Value.absent(),
    double? distanceMeters,
    int? elapsedSeconds,
    double? avgSpeedMps,
    bool? isPaused,
  }) => RunningStateData(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    lastTs: lastTs.present ? lastTs.value : this.lastTs,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
    isPaused: isPaused ?? this.isPaused,
  );
  RunningStateData copyWithCompanion(RunningStateCompanion data) {
    return RunningStateData(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastTs: data.lastTs.present ? data.lastTs.value : this.lastTs,
      distanceMeters:
          data.distanceMeters.present
              ? data.distanceMeters.value
              : this.distanceMeters,
      elapsedSeconds:
          data.elapsedSeconds.present
              ? data.elapsedSeconds.value
              : this.elapsedSeconds,
      avgSpeedMps:
          data.avgSpeedMps.present ? data.avgSpeedMps.value : this.avgSpeedMps,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunningStateData(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastTs: $lastTs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    lastTs,
    distanceMeters,
    elapsedSeconds,
    avgSpeedMps,
    isPaused,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunningStateData &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.lastTs == this.lastTs &&
          other.distanceMeters == this.distanceMeters &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.avgSpeedMps == this.avgSpeedMps &&
          other.isPaused == this.isPaused);
}

class RunningStateCompanion extends UpdateCompanion<RunningStateData> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> lastTs;
  final Value<double> distanceMeters;
  final Value<int> elapsedSeconds;
  final Value<double> avgSpeedMps;
  final Value<bool> isPaused;
  const RunningStateCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastTs = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.isPaused = const Value.absent(),
  });
  RunningStateCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.lastTs = const Value.absent(),
    required double distanceMeters,
    required int elapsedSeconds,
    required double avgSpeedMps,
    required bool isPaused,
  }) : startedAt = Value(startedAt),
       distanceMeters = Value(distanceMeters),
       elapsedSeconds = Value(elapsedSeconds),
       avgSpeedMps = Value(avgSpeedMps),
       isPaused = Value(isPaused);
  static Insertable<RunningStateData> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? lastTs,
    Expression<double>? distanceMeters,
    Expression<int>? elapsedSeconds,
    Expression<double>? avgSpeedMps,
    Expression<bool>? isPaused,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (lastTs != null) 'last_ts': lastTs,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (avgSpeedMps != null) 'avg_speed_mps': avgSpeedMps,
      if (isPaused != null) 'is_paused': isPaused,
    });
  }

  RunningStateCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? lastTs,
    Value<double>? distanceMeters,
    Value<int>? elapsedSeconds,
    Value<double>? avgSpeedMps,
    Value<bool>? isPaused,
  }) {
    return RunningStateCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      lastTs: lastTs ?? this.lastTs,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastTs.present) {
      map['last_ts'] = Variable<DateTime>(lastTs.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (avgSpeedMps.present) {
      map['avg_speed_mps'] = Variable<double>(avgSpeedMps.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunningStateCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastTs: $lastTs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $RunningTicksTable runningTicks = $RunningTicksTable(this);
  late final $RunningStateTable runningState = $RunningStateTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    runs,
    runningTicks,
    runningState,
  ];
}

typedef $$RunsTableCreateCompanionBuilder =
    RunsCompanion Function({
      required String id,
      required DateTime startedAt,
      required DateTime endedAt,
      required double distanceMeters,
      required int elapsedSeconds,
      required double avgSpeedMps,
      Value<int?> calories,
      required String pathJson,
      required String segmentsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$RunsTableUpdateCompanionBuilder =
    RunsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<double> distanceMeters,
      Value<int> elapsedSeconds,
      Value<double> avgSpeedMps,
      Value<int?> calories,
      Value<String> pathJson,
      Value<String> segmentsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathJson => $composableBuilder(
    column: $table.pathJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentsJson => $composableBuilder(
    column: $table.segmentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathJson => $composableBuilder(
    column: $table.pathJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentsJson => $composableBuilder(
    column: $table.segmentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<String> get pathJson =>
      $composableBuilder(column: $table.pathJson, builder: (column) => column);

  GeneratedColumn<String> get segmentsJson => $composableBuilder(
    column: $table.segmentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          Run,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (Run, BaseReferences<_$AppDatabase, $RunsTable, Run>),
          Run,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<String> pathJson = const Value.absent(),
                Value<String> segmentsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceMeters: distanceMeters,
                elapsedSeconds: elapsedSeconds,
                avgSpeedMps: avgSpeedMps,
                calories: calories,
                pathJson: pathJson,
                segmentsJson: segmentsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                required DateTime endedAt,
                required double distanceMeters,
                required int elapsedSeconds,
                required double avgSpeedMps,
                Value<int?> calories = const Value.absent(),
                required String pathJson,
                required String segmentsJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceMeters: distanceMeters,
                elapsedSeconds: elapsedSeconds,
                avgSpeedMps: avgSpeedMps,
                calories: calories,
                pathJson: pathJson,
                segmentsJson: segmentsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      Run,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (Run, BaseReferences<_$AppDatabase, $RunsTable, Run>),
      Run,
      PrefetchHooks Function()
    >;
typedef $$RunningTicksTableCreateCompanionBuilder =
    RunningTicksCompanion Function({
      Value<int> seq,
      required DateTime ts,
      required double lat,
      required double lng,
      Value<double?> altitude,
      Value<double?> accuracy,
      Value<double?> speedMps,
      Value<bool> isPaused,
    });
typedef $$RunningTicksTableUpdateCompanionBuilder =
    RunningTicksCompanion Function({
      Value<int> seq,
      Value<DateTime> ts,
      Value<double> lat,
      Value<double> lng,
      Value<double?> altitude,
      Value<double?> accuracy,
      Value<double?> speedMps,
      Value<bool> isPaused,
    });

class $$RunningTicksTableFilterComposer
    extends Composer<_$AppDatabase, $RunningTicksTable> {
  $$RunningTicksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunningTicksTableOrderingComposer
    extends Composer<_$AppDatabase, $RunningTicksTable> {
  $$RunningTicksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunningTicksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunningTicksTable> {
  $$RunningTicksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get speedMps =>
      $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);
}

class $$RunningTicksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunningTicksTable,
          RunningTick,
          $$RunningTicksTableFilterComposer,
          $$RunningTicksTableOrderingComposer,
          $$RunningTicksTableAnnotationComposer,
          $$RunningTicksTableCreateCompanionBuilder,
          $$RunningTicksTableUpdateCompanionBuilder,
          (
            RunningTick,
            BaseReferences<_$AppDatabase, $RunningTicksTable, RunningTick>,
          ),
          RunningTick,
          PrefetchHooks Function()
        > {
  $$RunningTicksTableTableManager(_$AppDatabase db, $RunningTicksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RunningTicksTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RunningTicksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$RunningTicksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => RunningTicksCompanion(
                seq: seq,
                ts: ts,
                lat: lat,
                lng: lng,
                altitude: altitude,
                accuracy: accuracy,
                speedMps: speedMps,
                isPaused: isPaused,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required DateTime ts,
                required double lat,
                required double lng,
                Value<double?> altitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => RunningTicksCompanion.insert(
                seq: seq,
                ts: ts,
                lat: lat,
                lng: lng,
                altitude: altitude,
                accuracy: accuracy,
                speedMps: speedMps,
                isPaused: isPaused,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunningTicksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunningTicksTable,
      RunningTick,
      $$RunningTicksTableFilterComposer,
      $$RunningTicksTableOrderingComposer,
      $$RunningTicksTableAnnotationComposer,
      $$RunningTicksTableCreateCompanionBuilder,
      $$RunningTicksTableUpdateCompanionBuilder,
      (
        RunningTick,
        BaseReferences<_$AppDatabase, $RunningTicksTable, RunningTick>,
      ),
      RunningTick,
      PrefetchHooks Function()
    >;
typedef $$RunningStateTableCreateCompanionBuilder =
    RunningStateCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> lastTs,
      required double distanceMeters,
      required int elapsedSeconds,
      required double avgSpeedMps,
      required bool isPaused,
    });
typedef $$RunningStateTableUpdateCompanionBuilder =
    RunningStateCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> lastTs,
      Value<double> distanceMeters,
      Value<int> elapsedSeconds,
      Value<double> avgSpeedMps,
      Value<bool> isPaused,
    });

class $$RunningStateTableFilterComposer
    extends Composer<_$AppDatabase, $RunningStateTable> {
  $$RunningStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTs => $composableBuilder(
    column: $table.lastTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunningStateTableOrderingComposer
    extends Composer<_$AppDatabase, $RunningStateTable> {
  $$RunningStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTs => $composableBuilder(
    column: $table.lastTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunningStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunningStateTable> {
  $$RunningStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastTs =>
      $composableBuilder(column: $table.lastTs, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);
}

class $$RunningStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunningStateTable,
          RunningStateData,
          $$RunningStateTableFilterComposer,
          $$RunningStateTableOrderingComposer,
          $$RunningStateTableAnnotationComposer,
          $$RunningStateTableCreateCompanionBuilder,
          $$RunningStateTableUpdateCompanionBuilder,
          (
            RunningStateData,
            BaseReferences<_$AppDatabase, $RunningStateTable, RunningStateData>,
          ),
          RunningStateData,
          PrefetchHooks Function()
        > {
  $$RunningStateTableTableManager(_$AppDatabase db, $RunningStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RunningStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RunningStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$RunningStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> lastTs = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => RunningStateCompanion(
                id: id,
                startedAt: startedAt,
                lastTs: lastTs,
                distanceMeters: distanceMeters,
                elapsedSeconds: elapsedSeconds,
                avgSpeedMps: avgSpeedMps,
                isPaused: isPaused,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> lastTs = const Value.absent(),
                required double distanceMeters,
                required int elapsedSeconds,
                required double avgSpeedMps,
                required bool isPaused,
              }) => RunningStateCompanion.insert(
                id: id,
                startedAt: startedAt,
                lastTs: lastTs,
                distanceMeters: distanceMeters,
                elapsedSeconds: elapsedSeconds,
                avgSpeedMps: avgSpeedMps,
                isPaused: isPaused,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunningStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunningStateTable,
      RunningStateData,
      $$RunningStateTableFilterComposer,
      $$RunningStateTableOrderingComposer,
      $$RunningStateTableAnnotationComposer,
      $$RunningStateTableCreateCompanionBuilder,
      $$RunningStateTableUpdateCompanionBuilder,
      (
        RunningStateData,
        BaseReferences<_$AppDatabase, $RunningStateTable, RunningStateData>,
      ),
      RunningStateData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$RunningTicksTableTableManager get runningTicks =>
      $$RunningTicksTableTableManager(_db, _db.runningTicks);
  $$RunningStateTableTableManager get runningState =>
      $$RunningStateTableTableManager(_db, _db.runningState);
}
