import 'package:health/health.dart';
import 'health_summary_provider.dart';

// TODO(B): 워크아웃 매칭 실패 시 fallback
// - startedAt~endedAt 범위의 HEART_RATE 샘플 평균(avgHr)
// - STEPS 샘플 합/시간으로 케이던스(avgCadence = steps/min) 계산
// - 칼로리는 ACTIVE_ENERGY_BURNED 샘플 합 또는 MET 추정치로 보강

class HealthSummaryProviderImpl implements HealthSummaryProvider {
  final Health _health = Health();

  // 13.2.1 기준: WORKOUT / HEART_RATE / ACTIVE_ENERGY_BURNED는 안정적
  final List<HealthDataType> _readTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  @override
  Future<HealthRunSummary?> fetchNearestSummary({
    required DateTime startedAt,
    required DateTime endedAt,
    required double distanceMeters,
  }) async {
    final ok = await _requestAuthorization();
    if (!ok) return null;

    final workout = await _findNearestRunningWorkout(
      startedAt: startedAt,
      endedAt: endedAt,
      distanceMeters: distanceMeters,
    );
    if (workout == null) return null;

    // ✅ 칼로리: workoutSummary.totalEnergyBurned 우선
    final calories = _extractCaloriesFromWorkoutSummary(workout);

    // ✅ 케이던스: workoutSummary.totalSteps 기반으로 steps/min 계산
    final avgCadence = _extractCadenceFromWorkoutSummary(workout);

    // ✅ 심박: 워크아웃 시간 범위 내 HEART_RATE 샘플 평균
    final avgHr = await _extractAvgHeartRateInRange(
      start: workout.dateFrom,
      end: workout.dateTo,
    );

    if (calories == null && avgHr == null && avgCadence == null) return null;

    return HealthRunSummary(
      calories: calories,
      avgHr: avgHr,
      avgCadence: avgCadence,
    );
  }

  Future<bool> _requestAuthorization() async {
    try {
      return await _health.requestAuthorization(_readTypes);
    } catch (_) {
      return false;
    }
  }

  Future<HealthDataPoint?> _findNearestRunningWorkout({
    required DateTime startedAt,
    required DateTime endedAt,
    required double distanceMeters,
  }) async {
    // 워크아웃은 시간 범위를 넉넉히 잡고 조회
    final from = startedAt.subtract(const Duration(hours: 6));
    final to = endedAt.add(const Duration(hours: 6));

    final workouts = await _health.getHealthDataFromTypes(
      types: [HealthDataType.WORKOUT],
      startTime: from,
      endTime: to,
    );

    HealthDataPoint? best;
    double bestScore = double.infinity;

    for (final w in workouts) {
      final ws = w.workoutSummary;

      // ✅ 러닝 워크아웃만 (workoutSummary가 없으면 매칭 정확도 낮아서 스킵 권장)
      if (ws == null) continue;
      if (!_isRunningWorkout(ws.workoutType as HealthWorkoutActivityType?)) continue;

      final startDiff = (w.dateFrom.difference(startedAt).inSeconds).abs();
      final endDiff = (w.dateTo.difference(endedAt).inSeconds).abs();

      final durationDiff =
      ((w.dateTo.difference(w.dateFrom)).inSeconds -
          endedAt.difference(startedAt).inSeconds)
          .abs();

      // 거리도 있으면 같이 비교
      final workoutDist = (ws.totalDistance ?? 0.0);
      final distDiff =
      workoutDist > 0 ? (workoutDist - distanceMeters).abs() : 0.0;

      // 시간 차 우선 + 거리 약간
      final score =
          startDiff * 1.0 + endDiff * 1.0 + durationDiff * 0.3 + distDiff * 0.02;

      if (score < bestScore) {
        bestScore = score;
        best = w;
      }
    }

    return best;
  }

  bool _isRunningWorkout(HealthWorkoutActivityType? t) {
    if (t == null) return true;
    // 13.2.1에는 workoutType이 HealthWorkoutActivityType 로 제공됨
    return t == HealthWorkoutActivityType.RUNNING ||
        t == HealthWorkoutActivityType.RUNNING_TREADMILL;
  }

  int? _extractCaloriesFromWorkoutSummary(HealthDataPoint workout) {
    final ws = workout.workoutSummary;
    final kcal = ws?.totalEnergyBurned;
    if (kcal != null && kcal.isFinite) return kcal.round();
    return null;
  }

  int? _extractCadenceFromWorkoutSummary(HealthDataPoint workout) {
    final ws = workout.workoutSummary;
    final steps = ws?.totalSteps;
    if (steps == null || steps <= 0) return null;

    final seconds = workout.dateTo.difference(workout.dateFrom).inSeconds;
    if (seconds <= 0) return null;

    final minutes = seconds / 60.0;
    final cadence = steps / minutes; // steps/min
    if (!cadence.isFinite) return null;

    // 러닝 케이던스 현실 범위만 통과
    if (cadence < 50 || cadence > 250) return null;

    return cadence.round();
  }

  Future<int?> _extractAvgHeartRateInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final points = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: start,
      endTime: end,
    );

    final values = <double>[];
    for (final p in points) {
      final val = p.value;
      if (val is NumericHealthValue) {
        final x = val.numericValue.toDouble();
        if (x.isFinite && x >= 20 && x <= 250) values.add(x);
      }
    }

    if (values.isEmpty) return null;
    final avg = values.reduce((a, b) => a + b) / values.length;
    return avg.round();
  }
}
