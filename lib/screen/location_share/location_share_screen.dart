import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:runmore/provider/live_share_provider.dart';
import 'package:runmore/screen/location_share/widget/room_header_panel.dart';
import 'package:runmore/screen/location_share/widget/runner_summary_bar.dart';
import 'package:runmore/util/color_hex.dart';
import 'package:runmore/util/live_position_ext.dart';

class LocationShareScreen extends StatelessWidget {
  const LocationShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: const [
          Positioned.fill(child: _LiveMapLayer()),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: RoomHeaderPanel(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: RunnerSummaryBar(),
          ),
        ],
      ),
    );
  }
}

class _LiveMapLayer extends StatefulWidget {
  const _LiveMapLayer();

  @override
  State<_LiveMapLayer> createState() => _LiveMapLayerState();
}

class _LiveMapLayerState extends State<_LiveMapLayer> {
  NaverMapController? _controller;
  bool _didInitCamera = false;

  @override
  Widget build(BuildContext context) {
    final live = context.watch<LiveShareProvider>();

    // ✅ build에서 즉시 clear/add 하지 말고 프레임 끝나고 1회만 실행
    if (_controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _controller == null) return;
        _updateOverlays(_controller!, live);
      });
    }

    return NaverMap(
      options: const NaverMapViewOptions(
        indoorEnable: false,
        locationButtonEnable: true,
        scaleBarEnable: true,
        rotationGesturesEnable: false,
      ),
      onMapReady: (controller) async {
        _controller = controller;
        context.read<LiveShareProvider>().setMapController(controller);

        // ✅ 지도 초기 화면을 내 위치로 (1회만)
        if (!_didInitCamera) {
          _didInitCamera = true;
          try {
            controller.setLocationTrackingMode(NLocationTrackingMode.follow);
            await Future.delayed(const Duration(milliseconds: 800));
            controller.setLocationTrackingMode(NLocationTrackingMode.noFollow);
          } catch (_) {
            // 위치 권한 없으면 무시
          }
        }

        _updateOverlays(controller, live);
      },
    );
  }

  Future<void> _updateOverlays(NaverMapController controller, LiveShareProvider live) async {
    final overlays = <NAddableOverlay>{};

    // ✅ “지금 달리는 러너(is_active=true)”만 지도에 표시
    final activeRunners = live.runners.where((r) => r.isActive).toList();

    for (final runner in activeRunners) {
      final segments = live.segmentsByRunner[runner.id] ?? [];

      final sorted = [...segments]..sort((a, b) => a.segmentTs.compareTo(b.segmentTs));

      for (int i = 0; i < sorted.length; i++) {
        final seg = sorted[i];
        final points = seg.polylinePoints;
        if (points.length < 2) continue;

        final alpha = 0.3 + (i / (sorted.length + 1)) * 0.5;
        final color = (runner.color ?? '#03A9F4').toColorOrDefault().withOpacity(alpha);

        overlays.add(
          NPathOverlay(
            id: 'route_${runner.id}_$i',
            coords: points,
            width: 6,
            color: color,
          ),
        );
      }

      if (segments.isNotEmpty) {
        final lastPoint = segments.first.lastPoint;
        if (lastPoint != null) {
          overlays.add(
            NMarker(
              id: 'marker_${runner.id}',
              position: lastPoint,
              caption: NOverlayCaption(text: runner.displayName, textSize: 12),
            ),
          );
        }
      }
    }

    await controller.clearOverlays();
    await controller.addOverlayAll(overlays);
  }
}