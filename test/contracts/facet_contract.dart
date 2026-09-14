import 'contract_test_helpers.dart';

void defineFacetContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) facetIds,
  required String Function(TSubject subject, String facetId) label,
}) {
  defineTypedContract<TSubject>(
    name: '$name facet contract',
    create: create,
    checks: [
      (subject) {
        final ids = facetIds(subject).toList(growable: false);
        expectUnique(ids, '$name facet IDs must be unique');
        for (final facetId in ids) {
          expectNonEmpty(
              label(subject, facetId), '$name facet $facetId needs a label');
        }
      },
    ],
  );
}
