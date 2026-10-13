import 'contract_test_helpers.dart';

void defineVocabularyContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Map<String, Iterable<String>> Function(TSubject subject)
      vocabularies,
}) {
  defineTypedContract<TSubject>(
    name: '$name vocabulary contract',
    create: create,
    checks: [
      (subject) {
        final values = vocabularies(subject);
        expectUnique(values.keys, '$name vocabulary IDs must be unique');
        for (final entry in values.entries) {
          expectNonEmpty(entry.key, '$name vocabulary IDs must not be empty');
          expectUnique(entry.value,
              '$name vocabulary ${entry.key} values must be unique');
        }
      },
    ],
  );
}
