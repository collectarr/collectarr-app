import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:uuid/uuid.dart';

/// Applies and retries one kind-owned personal sync entity type.
///
/// The shared sync host owns transport batching. The kind codec owns payload
/// interpretation and its local repository lifecycle.
abstract interface class KindSyncEntityCodec {
  String get entityType;

  Future<void> applyPullBatch(LocalDatabase db, List<JsonMap> entities);

  Future<SyncChange?> retryRejected(
    SyncRejectedChange change, {
    required LocalDatabase db,
    required DateTime changedAt,
    required Uuid uuid,
  });
}
