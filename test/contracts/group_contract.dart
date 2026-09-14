import 'contract_test_helpers.dart';

void defineGroupContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) groupIds,
  required String Function(TSubject subject, String groupId, Object value)
      bucket,
}) {
  defineTypedContract<TSubject>(
    name: '$name group contract',
    create: create,
    checks: [
      (subject) {
        final ids = groupIds(subject).toList(growable: false);
        expectUnique(ids, '$name group IDs must be unique');
        for (final groupId in ids) {
          expectNonEmpty(
            bucket(subject, groupId, Object()),
            '$name group $groupId must produce a bucket value',
          );
        }
      },
    ],
  );
}
