import 'package:flutter_test/flutter_test.dart';

import '../contract_test_helpers.dart';

void defineCalendarContributorContract<TContributor, TContext, TEvent>({
  required String name,
  required TContributor Function() create,
  required Iterable<TEvent> Function(
    TContributor contributor,
    TContext context,
  ) project,
  required String Function(TEvent event) id,
  required String Function(TEvent event) title,
  required String Function(TEvent event) kindReference,
  required DateTime Function(TEvent event) startsAt,
  required DateTime Function(TEvent event) endsAt,
  required TContext Function() createContext,
}) {
  defineTypedContract<TContributor>(
    name: '$name calendar contributor contract',
    create: create,
    checks: [
      (contributor) {
        final events = project(contributor, createContext()).toList();
        final ids = events.map(id).toList(growable: false);
        expectUnique(ids, '$name calendar event IDs must be unique');
        for (final event in events) {
          expectNonEmpty(id(event), '$name calendar event ID is required');
          expectNonEmpty(
              title(event), '$name calendar event title is required');
          expectNonEmpty(
            kindReference(event),
            '$name calendar event kind reference is required',
          );
          expect(
            startsAt(event).compareTo(endsAt(event)) <= 0,
            isTrue,
            reason: '$name calendar event range must be ordered',
          );
        }
      },
    ],
  );
}
