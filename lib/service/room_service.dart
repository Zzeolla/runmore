import 'package:runmore/util/rest_headers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supa = Supabase.instance.client;

class RoomService {
  /// 방 생성: shareCode, writeToken, roomId 반환
  static Future<({String roomId, String shareCode, String writeToken})> createRoom({String? title}) async {   //todo: 나중에 방 이름은 필수로 하자
    final rows = await _supa
        .rpc('create_room', params: {'p_title': title})
        .select(); // rpc도 select()로 결과 받음

    if (rows.isNotEmpty) {
      final row = rows.first;
      return (
        roomId: row['id'] as String,
        shareCode: row['share_code'] as String,
        writeToken: row['write_token'] as String,
      );
    } else {
      throw Exception('create_room 결과가 비어있습니다.');
    }
  }

  /// shareCode로 방 기본 정보 가져오기 (roomId, is_active 등)
  static Future<Map<String, dynamic>> getRoomByShareCode(String shareCode) async {
    return await withRestHeaders({'X-Share-Code': shareCode}, () async {
      final row = await _supa
          .from('rooms')
          .select('id,title,is_active,created_at')
          .single();
      return Map<String, dynamic>.from(row);
    });
  }

  /// 방 종료 (러너만, writeToken 필요)
  static Future<void> endRoom({required String roomId, required String writeToken}) async {
    await withRestHeaders({'X-Write-Token': writeToken}, () async {
      await _supa
          .from('rooms')
          .update({'is_active': false})
          .eq('id', roomId);
    });
  }
}
