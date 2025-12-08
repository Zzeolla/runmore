import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:runmore/model/run_stats.dart';
import 'package:runmore/model/run_tick.dart';

class RunService {
  StreamSubscription<Position>? _sub;
  final List<RunTick> _ticks = [];
  DateTime? _startTs;
  final _tickCtl = StreamController<RunTick>.broadcast();
  final _statsCtl = StreamController<RunStats>.broadcast();

  Stream<RunTick> get tickStream => _tickCtl.stream;
  Stream<RunStats> get statsStream => _statsCtl.stream;

  Future<bool> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  void start() {
    _ticks.clear();
    _startTs = DateTime.now();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // 5m 이동마다 콜백
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen((p) {
      final tick = RunTick(
          ts: DateTime.now(),
          lat: p.latitude,
          lng: p.longitude,
          altitude: p.altitude,
          speedMps: p.speed.isNegative ? 0 : p.speed, // m/s
        );
      _ticks.add(tick);
      _tickCtl.add(tick);
      _emitStats();
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _emitStats();
  }

  void dispose() {
    _sub?.cancel();
    _statsCtl.close();
    _tickCtl.close();
  }

  // ===== 내부 =====
  void _emitStats() {
    final elapsed = _startTs == null ? 0 : DateTime.now().difference(_startTs!).inSeconds;
    final dist = _distance();
    final avg = elapsed > 0 ? dist / elapsed : 0.0;
    _statsCtl.add(RunStats(distanceMeters: dist, elapsedSeconds: elapsed, avgSpeedMps: avg));
  }

  double _distance() {
    double total = 0;
    for (int i = 1; i < _ticks.length; i++) {
      total += _haversine(_ticks[i - 1].lat, _ticks[i - 1].lng, _ticks[i].lat, _ticks[i].lng);
    }
    return total;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRad(double d) => d * math.pi / 180.0;
}
