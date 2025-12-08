import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:runmore/model/run_stats.dart';
import 'package:runmore/service/run_service.dart';

class RunProvider extends ChangeNotifier {
  final RunService _svc = RunService();
  RunStats _stats = const RunStats(distanceMeters: 0, elapsedSeconds: 0, avgSpeedMps: 0);
  bool _isRunning = false;
  final List<NLatLng> _path = [];

  RunStats get stats => _stats;
  bool get isRunning => _isRunning;
  List<NLatLng> get path => List.unmodifiable(_path);

  Future<bool> ensurePermission() => _svc.ensurePermission();

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    _svc.start();
    _svc.statsStream.listen((s) {
      _stats = s;
      notifyListeners();
    });

    _svc.tickStream.listen((t) {
      _path.add(NLatLng(t.lat, t.lng));
      notifyListeners();
    });

    notifyListeners();
  }

  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _svc.stop();
    notifyListeners();
  }

  void resetPath() {
    _path.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _svc.dispose();
    super.dispose();
  }
}
