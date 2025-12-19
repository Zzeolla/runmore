import 'package:geolocator/geolocator.dart';
import 'package:runmore/model/run_tick.dart';
import 'package:runmore/model/pace_segment.dart';

List<PaceSegment> buildPaceSegments(List<RunTick> ticks) {
  if (ticks.length < 2) return [];

  // ----- 노이즈 필터 파라미터 -----
  const double minDistance = 5.0;     // 5m 이상
  const double maxDistance = 80.0;    // 1초에 80m 넘으면 GPS 헛점
  const double minSpeedMps = 1.0;        // 1m/s (3.6km/h) 이상 → 러닝/걷기만 인정
  // -------------------------------

  final List<PaceSegment> segments = [];

  double accDist = 0.0;     // 현재 구간에 누적된 거리(m) (아직 1km 안 채움)
  int accTime = 0;          // 현재 구간에 누적된 시간(초)
  int segIndex = 1;

  int cumulativeSeconds = 0; // 여기까지 누적 시간(초)

  for (int i = 1; i < ticks.length; i++) {
    final prev = ticks[i - 1];
    final curr = ticks[i];

    final dt = curr.ts.difference(prev.ts).inSeconds;
    if (dt <= 0) continue;

    final dist = Geolocator.distanceBetween(
      prev.lat,
      prev.lng,
      curr.lat,
      curr.lng,
    ); // m

    final speed = dist / dt;

    final bool tooSmallMove = dist <= minDistance && speed <= minSpeedMps;
    final bool tooBigJump = dist >= maxDistance;

    if (tooSmallMove || tooBigJump) continue;

    accDist += dist;
    accTime += dt;

    // ⚠️ 한 번의 샘플로 1km를 여러 번 넘을 수도 있으니 while
    while (accDist >= 1000.0) {
      // 지금까지 쌓인 accDist/accTime 중에서 딱 1km에 해당하는 시간만 비율로 떼기
      final ratio = 1000.0 / accDist;         // 1km가 accDist의 몇 %
      final segSeconds = (accTime * ratio).round();

      cumulativeSeconds += segSeconds;

      segments.add(
        PaceSegment(
          index: segIndex,
          distance: 1.0,            // 정확히 1km
          seconds: segSeconds,      // 이 1km에 걸린 시간
          cumulativeSeconds: cumulativeSeconds, // 여기까지 누적
        ),
      );

      segIndex++;

      // 남은 거리/시간은 다음 구간으로 넘기기
      accDist = accDist - 1000.0;
      accTime = accTime - segSeconds;
      if (accTime < 0) accTime = 0;
    }
  }

  // 마지막 남은 구간 (0.1km 이상만)
  final remainKm = accDist / 1000.0;
  if (remainKm >= 0.10 && accTime > 0) {
    cumulativeSeconds += accTime;

    segments.add(
      PaceSegment(
        index: segIndex,
        distance: remainKm,        // 0.12km 이런 식
        seconds: accTime,          // 그 거리만큼 걸린 시간
        cumulativeSeconds: cumulativeSeconds,
      ),
    );
  }

  return segments;
}
