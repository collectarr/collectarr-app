import 'contract_test_helpers.dart';

void defineSortContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) sortIds,
  required int Function(
          TSubject subject, String sortId, Object left, Object right)
      compare,
}) {
  defineTypedContract<TSubject>(
    name: '$name sort contract',
    create: create,
    checks: [
      (subject) {
        final ids = sortIds(subject).toList(growable: false);
        expectContract(ids.isNotEmpty, '$name must expose at least one sort');
        expectUnique(ids, '$name sort IDs must be unique');
        for (final sortId in ids) {
          compare(subject, sortId, Object(), Object());
        }
      },
    ],
  );
}
