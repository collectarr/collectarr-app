import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/sync/kind_sync_entity_codec.dart';

/// Music-owned personal sync lifecycle for listening events.
final class MusicListeningSyncCodec implements KindSyncEntityCodec {
  const MusicListeningSyncCodec();

  @override
  String get entityType => 'music_listen_event';

  @override
  Future<void> applyPullBatch(LocalDatabase db, List<JsonMap> entities) async {
    final repository = MusicListeningRepository(db);
    await repository.upsertAll(entities.map(_eventFromEntity));
  }

  MusicListenEvent _eventFromEntity(JsonMap entity) {
    final action = entity['action'] as String;
    final changedAt = entity['client_changed_at'] as String;
    final payload = _entityPayload(entity);
    return MusicListenEvent.fromJson({
      ...payload,
      'id': entity['entity_id'],
      'updated_at': payload['updated_at'] ?? changedAt,
      'deleted_at': action == 'delete' ? changedAt : payload['deleted_at'],
    });
  }
}

JsonMap _entityPayload(JsonMap entity) {
  final payload = entity['payload'];
  if (payload is! Map) {
    throw const FormatException('Music listen event requires a payload map.');
  }
  return Map<String, dynamic>.from(payload);
}
