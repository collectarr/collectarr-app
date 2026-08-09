import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';

typedef SyncScheduler = void Function();

class CollectionMutationRunner {
  const CollectionMutationRunner({
    required this.database,
    required this.events,
    this.syncScheduler,
  });

  final LocalDatabase database;
  final CollectionEventBus events;
  final SyncScheduler? syncScheduler;

  Future<T> run<T>({
    required Future<T> Function() action,
    List<CollectionEvent> eventsToEmit = const [],
    bool triggerSync = true,
  }) async {
    final result = await database.transaction(() async {
      return await action();
    });

    for (final event in eventsToEmit) {
      events.emit(event);
    }

    if (triggerSync && syncScheduler != null) {
      syncScheduler!();
    }

    return result;
  }
}
