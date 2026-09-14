import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';

typedef SyncScheduler = void Function();
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
    this.mutationOriginHandler,
    this.localMutationHandler,
  });

  final LocalDatabase database;
  final CollectionEventBus events;
  final SyncScheduler? syncScheduler;
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

    if (mutationOriginHandler != null) {
      await mutationOriginHandler!(origin);
    }
    if (localRef != null && localMutationHandler != null) {
      await localMutationHandler!(localRef, origin);
    }

    if (triggerSync && syncScheduler != null) {
      syncScheduler!();
    }

    return result;
  }
}
