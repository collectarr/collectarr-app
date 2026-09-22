import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';

typedef SyncScheduler = void Function();
typedef CollectionProjectionInvalidator = void Function();
typedef MutationOriginHandler = FutureOr<void> Function(MutationOrigin origin);
typedef LocalMutationHandler = FutureOr<void> Function(
  CatalogEntityRef localRef,
  MutationOrigin origin,
);

class CollectionMutationRunner {
  const CollectionMutationRunner({
    required this.database,
    required this.events,
    this.syncScheduler,
    this.projectionInvalidator,
    this.mutationOriginHandler,
    this.localMutationHandler,
  });

  final LocalDatabase database;
  final CollectionEventBus events;
  final SyncScheduler? syncScheduler;
  final CollectionProjectionInvalidator? projectionInvalidator;
  final MutationOriginHandler? mutationOriginHandler;
  final LocalMutationHandler? localMutationHandler;

  Future<T> run<T>({
    required Future<T> Function() action,
    List<CollectionEvent> eventsToEmit = const [],
    bool triggerSync = true,
    MutationOrigin origin = MutationOrigin.user,
    CatalogEntityRef? localRef,
  }) async {
    final result = await database.transaction(() async {
      return await action();
    });

    for (final event in eventsToEmit) {
      events.emit(event);
    }

    // The local transaction is authoritative for the desktop collection.
    // Provider bridges and sync are side effects; a connection failure must
    // never leave the local projection stale or turn a successful local
    // delete into a failed UI action.
    projectionInvalidator?.call();

    if (mutationOriginHandler != null) {
      try {
        await mutationOriginHandler!(origin);
      } catch (_) {
        // The local mutation remains valid when an optional external bridge
        // is unavailable. The queued change is still available for retry.
      }
    }
    if (localRef != null && localMutationHandler != null) {
      try {
        await localMutationHandler!(localRef, origin);
      } catch (_) {
        // Provider state is best-effort and must not roll back local data.
      }
    }

    if (triggerSync && syncScheduler != null) {
      try {
        syncScheduler!();
      } catch (_) {
        // Sync will remain pending and can be retried from the sync surface.
      }
    }

    return result;
  }
}
