import 'contract_test_helpers.dart';

void defineWorkspaceContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required String Function(TSubject subject) title,
  required Iterable<String> Function(TSubject subject) fieldIds,
  required Iterable<String> Function(TSubject subject) sortIds,
}) {
  defineTypedContract<TSubject>(
    name: '$name workspace contract',
    create: create,
    checks: [
      (subject) =>
          expectNonEmpty(title(subject), '$name workspace needs a title'),
      (subject) => expectUnique(
          fieldIds(subject), '$name workspace fields must be unique'),
      (subject) => expectUnique(
          sortIds(subject), '$name workspace sorts must be unique'),
    ],
  );
}
