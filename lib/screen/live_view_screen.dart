import 'package:flutter/material.dart';
import 'package:runmore/service/room_service.dart';
import 'package:runmore/service/viewer_poller.dart';

class LiveViewScreen extends StatefulWidget {
  final String? initialShareCode;
  const LiveViewScreen({super.key, this.initialShareCode});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  final _controller = TextEditingController();
  ViewerPoller? _poller;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    if (widget.initialShareCode != null) {
      _controller.text = widget.initialShareCode!;
      _connect(widget.initialShareCode!);
    }
  }

  Future<void> _connect(String code) async {
    final room = await RoomService.getRoomByShareCode(code);
    final rid = room['id'] as String;
    _roomId = rid;

    _poller?.stop();
    _poller = ViewerPoller(shareCode: code, roomId: rid)..start();
    setState(() {});
  }

  @override
  void dispose() {
    _poller?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('실시간 보기(뷰어)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: '공유 코드 입력',
                    hintText: '예: a1B2c3D4',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _connect(_controller.text.trim()),
                child: const Text('접속'),
              )
            ]),
            const SizedBox(height: 16),
            if (_poller == null)
              const Text('공유 코드를 입력 후 접속하세요.')
            else
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _poller!.positions,
                  builder: (_, list, __) {
                    if (list.isEmpty) {
                      return const Center(child: Text('아직 위치 데이터가 없습니다.'));
                    }
                    final last = list.last;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('roomId: $_roomId'),
                        Text('최근 좌표: ${last['lat']}, ${last['lng']}'),
                        Text('포인트 수: ${list.length}'),
                        const SizedBox(height: 12),
                        const Text('※ 지도 연동은 추후(네이버/구글맵)에서 Polyline + Marker로 표시'),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
