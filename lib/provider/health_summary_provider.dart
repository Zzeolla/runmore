abstract class HealthSummaryProvider {
  Future<HealthRunSummary?> fetchNearestSummary({
    required DateTime startedAt,
    required DateTime endedAt,
    required double distanceMeters,
  });
}

class HealthRunSummary {
  final int? calories;
  final int? avgHr;
  final int? avgCadence;
  const HealthRunSummary({this.calories, this.avgHr, this.avgCadence});
}