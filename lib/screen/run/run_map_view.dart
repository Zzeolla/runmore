import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class RunMapView extends StatefulWidget {
  final List<NLatLng> path;

  const RunMapView({
    super.key,
    required this.path,
  });

  @override
  State<RunMapView> createState() => _RunMapViewState();
}

class _RunMapViewState extends State<RunMapView> {
  NaverMapController? _mapController;
  NPathOverlay? _routeOverlay;

  @override
  void didUpdateWidget(covariant RunMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // path가 변경될 때 오버레이 업데이트
    if (oldWidget.path != widget.path) {
      _updateRoute(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = widget.path.isNotEmpty
        ? widget.path.last
        : const NLatLng(37.5665, 126.9780);

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: last,
          zoom: 15,
        ),
        locationButtonEnable: true,
        scaleBarEnable: true,
        rotationGesturesEnable: false,
      ),
      onMapReady: (controller) async {
        _mapController = controller;

        // Follow 모드
        controller.setLocationTrackingMode(NLocationTrackingMode.follow);

        // 초기 경로가 2개 이상이면 그려주기
        await _updateRoute(widget.path);

        // 초기 카메라 이동
        if (widget.path.isNotEmpty) {
          await _mapController!.updateCamera(
            NCameraUpdate.scrollAndZoomTo(target: widget.path.last, zoom: 16),
          );
        }
      },
    );
  }

  Future<void> _updateRoute(List<NLatLng> points) async {
    if (_mapController == null) return;

    if (points.length < 2) {
      // 점 1개 이하면 경로 그리지 않음
      return;
    }

    // 같은 id로 addOverlay하면 업데이트처럼 동작 (기존 코드 유지)
    _routeOverlay = NPathOverlay(
      id: 'route',
      coords: points,
      width: 6,
      color: Colors.blue,
    );
    await _mapController!.addOverlay(_routeOverlay!);

    // 최신 좌표로 카메라 이동
    await _mapController!.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: points.last, zoom: 16),
    );
  }
}
