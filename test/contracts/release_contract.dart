import 'contract_test_helpers.dart';

void defineReleaseContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required String Function(TSubject subject) id,
  required String Function(TSubject subject) title,
}) {
  defineTypedContract<TSubject>(
    name: '$name release contract',
    create: create,
    checks: [
      (subject) => expectNonEmpty(id(subject), '$name release needs an ID'),
      (subject) =>
          expectNonEmpty(title(subject), '$name release needs a title'),
    ],
  );
}
