import 'dart:async';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
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
    LibraryEntryRef libraryEntryRef, {
    required MetadataFieldId fieldId,
    required String overrideValue,
    String? originalValue,
  }) async {
    final now = DateTime.now().toUtc();
    requireKnownLibraryEntryRef(libraryEntryRef, 'libraryEntryRef');
    if (!fieldId.appliesTo(libraryEntryRef.kind)) {
      throw ArgumentError.value(
        fieldId,
        'fieldId',
        'Metadata field belongs to ${fieldId.kind.apiValue}, '
            'not ${libraryEntryRef.kind.apiValue}',
      );
    }
    if (fieldId.value.trim().isEmpty) {
      throw ArgumentError.value(
        fieldId,
        'fieldId',
        'Metadata field key must not be empty.',
      );
    }
    if (overrideValue.trim().isEmpty) {
      throw ArgumentError.value(
        overrideValue,
        'overrideValue',
        'Metadata override value must not be empty.',
      );
    }
    final existing = await overrides.findByField(libraryEntryRef, fieldId);

    final override = UserMetadataOverride(
      id: existing?.id ?? idGenerator(),
      libraryEntryRef: libraryEntryRef,
      fieldId: fieldId,
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
      eventsToEmit: [MetadataOverrideChanged(libraryEntryRef)],
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
      eventsToEmit: [MetadataOverrideChanged(override.libraryEntryRef)],
    );
  }

  SyncChange _syncChangeForMetadataOverride(
    UserMetadataOverride override,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'metadata_override:${override.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'metadata_override',
      entityId: override.id,
      action: action,
      payload: override.toSyncPayload(),
      clientChangedAt: now,
    );
  }
}
