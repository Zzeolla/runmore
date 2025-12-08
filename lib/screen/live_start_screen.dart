import 'package:flutter/material.dart';
import 'package:runmore/service/room_service.dart';
import 'package:runmore/service/runner_uploader.dart';

class LiveStartScreen extends StatefulWidget {
  const LiveStartScreen({super.key});

  @override
  State<LiveStartScreen> createState() => _LiveStartScreenState();
}

class _LiveStartScreenState extends State<LiveStartScreen> {
  String? roomId;
  String? shareCode;
  String? writeToken;
  RunnerUploader? _uploader;
  bool running = false;

  Future<void> _createRoom() async {
    final created = await RoomService.createRoom(title: '런모아 라이브');
    setState(() {
      roomId = created.roomId;
      shareCode = created.shareCode;
      writeToken = created.writeToken;
    });
  }

  Future<void> _startUpload() async {
    if (roomId == null || writeToken == null) return;
    _uploader = RunnerUploader(roomId: roomId!, writeToken: writeToken!);
    await _uploader!.start();
    setState(() => running = true);
  }

  Future<void> _stopUpload() async {
    await _uploader?.stop();
    setState(() => running = false);
  }

  Future<void> _endRoom() async {
    if (roomId == null || writeToken == null) return;
    await RoomService.endRoom(roomId: roomId!, writeToken: writeToken!);
    await _stopUpload();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('세션 종료')));
  }

  @override
  Widget build(BuildContext context) {
    final linkText = shareCode == null ? '' : '공유 링크: https://runmore.app/r/$shareCode';

    return Scaffold(
      appBar: AppBar(title: const Text('라이브 공유 시작(러너)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _createRoom,
              child: const Text('방 생성'),
            ),
            const SizedBox(height: 12),
            if (roomId != null) Text('roomId: $roomId'),
            if (shareCode != null) SelectableText(linkText),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (roomId != null && !running) ? _startUpload : null,
                    child: const Text('업로드 시작'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: running ? _stopUpload : null,
                    child: const Text('일시정지'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: (roomId != null) ? _endRoom : null,
              child: const Text('세션 종료'),
            ),
            const Spacer(),
            if (shareCode != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/view', arguments: shareCode);
                },
                child: const Text('뷰어 화면으로 테스트 이동'),
              ),
          ],
        ),
      ),
    );
  }
}
