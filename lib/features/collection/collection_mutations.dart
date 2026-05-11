import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CollectionMutations {
  CollectionMutations(this.ref);

  final Ref ref;
  final Uuid _uuid = const Uuid();

  Future<void> addItem(String itemId) async {
    final payload = {'item_id': itemId};
    try {
      await ref.read(apiClientProvider).addToCollection(payload);
    } catch (_) {
      final db = ref.read(localDatabaseProvider);
      await SyncQueueRepository(db).enqueue(
        SyncChange(
          entityType: 'owned_item',
          entityId: _uuid.v4(),
          action: 'upsert',
          payload: payload,
          clientChangedAt: DateTime.now().toUtc(),
        ),
      );
      await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    }
  }
}

final collectionMutationsProvider = Provider<CollectionMutations>((ref) {
  return CollectionMutations(ref);
});

