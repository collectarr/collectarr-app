import 'contract_test_helpers.dart';

void defineKindIdentityContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required String Function(TSubject subject) kindKey,
  required String Function(TSubject subject) singularLabel,
  required String Function(TSubject subject) pluralLabel,
  required String Function(TSubject subject) countLabel,
  String Function(TSubject subject)? title,
}) {
  defineTypedContract<TSubject>(
    name: '$name kind identity contract',
    create: create,
    checks: [
      (subject) =>
          expectNonEmpty(kindKey(subject), '$name must have a kind key'),
      (subject) => expectNonEmpty(
            singularLabel(subject),
            '$name must have a singular label',
          ),
      (subject) => expectNonEmpty(
            pluralLabel(subject),
            '$name must have a plural label',
          ),
      (subject) => expectSame(
            countLabel(subject),
            singularLabel(subject),
            '$name singular count label must use the singular label',
          ),
      (subject) => expectNonEmpty(
            title?.call(subject) ?? kindKey(subject),
            '$name must have a title',
          ),
    ],
  );
}
