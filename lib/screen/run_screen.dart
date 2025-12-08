import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:runmore/provider/run_provider.dart';
import 'package:runmore/util/pace.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  NaverMapController? _mapController;
  NPathOverlay? _routeOverlay;

  @override
  Widget build(BuildContext context) {
    final run = context.watch<RunProvider>();
    final km = run.stats.distanceMeters / 1000.0;
    final pace = formatPace(run.stats.avgSpeedMps);
    final time = formatHms(run.stats.elapsedSeconds);

    _updateRoute(run.path);

    return Scaffold(
      appBar: AppBar(title: const Text('런모아')),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: run.path.isNotEmpty ? run.path.last : const NLatLng(37.5665, 126.9780),
                zoom: 15,
              ),
              locationButtonEnable: true,
              scaleBarEnable: true,
              rotationGesturesEnable: false,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              // 현재 위치 추적 모드: 지도 카메라 따라가기(Follow) 원하면 아래 사용
              controller.setLocationTrackingMode(NLocationTrackingMode.follow);

              // 최초 경로 오버레이 생성
              _routeOverlay = NPathOverlay(
                id: 'route',
                coords: run.path,
                width: 6,
                color: Colors.blue,
              );
              await _mapController!.addOverlay(_routeOverlay!);

              // 경로가 있다면 카메라 이동 (이 함수는 Future<bool> 반환)
              if (run.path.isNotEmpty) {
                await _mapController!.updateCamera(
                  NCameraUpdate.scrollAndZoomTo(target: run.path.last, zoom: 16),
                );
              }
            },
          ),

          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: _StatsPanel(
              km: km,
              pace: pace,
              time: time,
              isRunning: run.isRunning,
              onStart: () async {
                final ok = await run.ensurePermission();
                if (!ok && mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('위치 권한을 허용해 주세요.')));
                  return;
                }
                run.resetPath();
                run.start();
              },
              onStop: run.stop,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRoute(List<NLatLng> points) async {
    if (_mapController == null || points.isEmpty) return;

    // 경로 좌표 갱신
    _routeOverlay = NPathOverlay(id: 'route', coords: points, width: 6, color: Colors.blue);
    await _mapController!.addOverlay(_routeOverlay!); // 같은 id로 업데이트

    // 카메라를 최신 좌표로 부드럽게 이동
    await _mapController!.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: points.last, zoom: 16),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final double km;
  final String pace;
  final String time;
  final bool isRunning;
  final VoidCallback onStop;
  final Future<void> Function() onStart;

  const _StatsPanel({
    required this.km,
    required this.pace,
    required this.time,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _metric('거리', '${km.toStringAsFixed(2)} km'),
                _metric('페이스', pace),
                _metric('시간', time),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isRunning)
                  FilledButton(onPressed: onStart, child: const Text('시작'))
                else
                  FilledButton.tonal(onPressed: onStop, child: const Text('정지')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
