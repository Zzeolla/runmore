import 'package:runmore/model/run_record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRunRepository {
  final SupabaseClient client;

  SupabaseRunRepository({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

  Future<void> upsertRun(RunRecord record) async {
    await client.from('runs').upsert(
      record.toJson(),
      onConflict: 'id',
    );
  }

  /// ids 목록 중 이미 존재하는 run id들을 Set으로 반환
  Future<Set<String>> fetchExistingIds(List<String> ids) async {
    if (ids.isEmpty) return <String>{};

    final existing = await client
        .from('runs')
        .select('id')
        .inFilter('id', ids);

    return (existing as List)
        .map((e) => e['id'] as String)
        .toSet();
  }
}
