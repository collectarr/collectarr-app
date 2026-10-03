import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';

typedef SyncScheduler = void Function();
typedef CollectionProjectionInvalidator = void Function();

final Object _mutationContextKey = Object();

final class _MutationContext {
  _MutationContext(this.runner);

  final CollectionMutationRunner runner;
  final events = <CollectionEvent>[];
  bool triggerSync = false;
  bool invalidateProjection = false;
}

class CollectionMutationRunner {
  const CollectionMutationRunner({
    required this.database,
    required this.events,
    this.syncScheduler,
    this.projectionInvalidator,
  });

  final LocalDatabase database;
  final CollectionEventBus events;
  final SyncScheduler? syncScheduler;
  final CollectionProjectionInvalidator? projectionInvalidator;

  Future<T> run<T>({
    required Future<T> Function() action,
    List<CollectionEvent> eventsToEmit = const [],
    bool triggerSync = true,
  }) async {
    final nestedContext = Zone.current[_mutationContextKey];
    if (nestedContext is _MutationContext &&
        identical(nestedContext.runner, this)) {
      final result = await action();
      nestedContext.events.addAll(eventsToEmit);
      nestedContext.triggerSync = nestedContext.triggerSync || triggerSync;
      nestedContext.invalidateProjection = true;
      return result;
    }

    final context = _MutationContext(this);
    final result = await database.transaction(
      () => runZoned(
        action,
        zoneValues: {_mutationContextKey: context},
      ),
    );
    context.events.addAll(eventsToEmit);

    for (final event in context.events) {
      events.emit(event);
    }

    // The local transaction is authoritative for the desktop collection.
    if (context.invalidateProjection || context.events.isNotEmpty) {
      projectionInvalidator?.call();
    }

    if ((context.triggerSync || triggerSync) && syncScheduler != null) {
      try {
        syncScheduler!();
      } catch (_) {
        // Sync will remain pending and can be retried from the sync surface.
      }
    }

    return result;
  }
}
