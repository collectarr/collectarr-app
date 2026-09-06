import 'package:flutter_test/flutter_test.dart';

import '../contract_test_helpers.dart';

void defineActivityContributorContract<TContributor, TContext, TEvent>({
  required String name,
  required TContributor Function() create,
  required Iterable<TEvent> Function(
    TContributor contributor,
    TContext context,
  ) project,
  required ActivityEventProjection<TEvent> projection,
  required TContext Function() createContext,
}) {
  defineTypedContract<TContributor>(
    name: '$name activity contributor contract',
    create: create,
    checks: [
      (contributor) {
        final events = project(contributor, createContext()).toList();
        expect(events, isNotEmpty,
            reason: '$name must project at least one activity event');
        final sourceIds = <String>[];
        for (final event in events) {
          expect(projection.timestamp(event), isNotNull,
              reason: '$name activity event timestamp is required');
          expect(projection.kind(event), isNotNull,
              reason: '$name activity event kind is required');
          final sourceId = projection.sourceId(event);
          if (sourceId != null && sourceId.trim().isNotEmpty) {
            sourceIds.add(sourceId);
          }
        }
        expectUnique(sourceIds, '$name activity source IDs must be unique');
      },
    ],
  );
}

final class ActivityEventProjection<TEvent> {
  const ActivityEventProjection({
    required this.timestamp,
    required this.kind,
    required this.sourceId,
  });

  final DateTime? Function(TEvent event) timestamp;
  final Object? Function(TEvent event) kind;
  final String? Function(TEvent event) sourceId;
}
