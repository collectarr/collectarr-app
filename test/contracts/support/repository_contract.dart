import 'contract_test_helpers.dart';

void defineRepositoryContract<TSubject, TId>({
  required String name,
  required TSubject Function() create,
  required TId Function(TSubject subject) idOf,
  required Future<void> Function(TSubject subject) save,
  required Future<TSubject?> Function(TId id) find,
  required bool Function(TSubject left, TSubject right) equals,
}) {
  defineAsyncTypedContract<TSubject>(
    name: '$name repository contract',
    create: create,
    check: (subject) async {
      await save(subject);
      final loaded = await find(idOf(subject));
      expectContract(loaded != null, '$name repository must reload saved data');
      expectContract(
        equals(subject, loaded as TSubject),
        '$name repository must preserve typed data',
      );
    },
  );
}
