import 'contract_test_helpers.dart';

void defineFieldsContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) fieldIds,
  required String Function(TSubject subject, String fieldId) label,
}) {
  defineTypedContract<TSubject>(
    name: '$name fields contract',
    create: create,
    checks: [
      (subject) {
        final ids = fieldIds(subject).toList(growable: false);
        expectContract(ids.isNotEmpty, '$name must expose at least one field');
        expectUnique(ids, '$name field IDs must be unique');
        for (final fieldId in ids) {
          expectNonEmpty(
              label(subject, fieldId), '$name field $fieldId needs a label');
        }
      },
    ],
  );
}
