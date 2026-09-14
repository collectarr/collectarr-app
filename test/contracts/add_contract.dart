import 'contract_test_helpers.dart';

void defineAddContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) fieldIds,
  required String Function(TSubject subject, String fieldId) label,
}) {
  defineTypedContract<TSubject>(
    name: '$name add contract',
    create: create,
    checks: [
      (subject) {
        final ids = fieldIds(subject).toList(growable: false);
        expectUnique(ids, '$name add field IDs must be unique');
        for (final fieldId in ids) {
          expectNonEmpty(label(subject, fieldId),
              '$name add field $fieldId needs a label');
        }
      },
    ],
  );
}
