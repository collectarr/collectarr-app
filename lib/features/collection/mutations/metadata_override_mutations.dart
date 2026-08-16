import 'dart:async';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class MetadataOverrideMutations {
  const MetadataOverrideMutations({
    required this.overrides,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  });

  final UserMetadataOverridesCacheRepository overrides;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<UserMetadataOverride> setMetadataOverride(
    String itemId, {
    required String fieldPath,
    required String overrideValue,
    String? originalValue,
    String? editionId,
    String? variantId,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await overrides.findByField(
      itemId,
      fieldPath,
      editionId: editionId,
      variantId: variantId,
    );

    final override = UserMetadataOverride(
      id: existing?.id ?? idGenerator(),
      itemId: itemId,
      editionId: editionId,
      variantId: variantId,
      fieldPath: fieldPath,
      originalValue: originalValue ?? existing?.originalValue,
      overrideValue: overrideValue,
      updatedAt: now,
    );

    await mutationRunner.run(
      action: () async {
        await overrides.upsert(override);
        await syncQueue
            .enqueue(_syncChangeForMetadataOverride(override, 'upsert', now));
      },
      eventsToEmit: [MetadataOverrideChanged(itemId)],
    );

    return override;
  }

  Future<void> removeMetadataOverride(UserMetadataOverride override) async {
    final now = DateTime.now().toUtc();
    final deleted = override.copyWith(deletedAt: now, updatedAt: now);

    await mutationRunner.run(
      action: () async {
        await overrides.markDeleted(override, now);
        await syncQueue
            .enqueue(_syncChangeForMetadataOverride(deleted, 'delete', now));
      },
      eventsToEmit: [MetadataOverrideChanged(override.itemId)],
    );
  }

  SyncChange _syncChangeForMetadataOverride(
    UserMetadataOverride override,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'metadata_override:${override.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'user_metadata_override',
      entityId: override.id,
      action: action,
      payload: override.toSyncPayload(),
      clientChangedAt: now,
    );
  }
}
