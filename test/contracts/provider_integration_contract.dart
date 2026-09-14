import 'contract_test_helpers.dart';

void defineProviderIntegrationContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) providerIds,
  required Future<Object?> Function(TSubject subject, String providerId) load,
}) {
  defineAsyncTypedContract<TSubject>(
    name: '$name provider integration contract',
    create: create,
    check: (subject) async {
      final ids = providerIds(subject).toList(growable: false);
      expectUnique(ids, '$name provider IDs must be unique');
      for (final providerId in ids) {
        expectNonEmpty(providerId, '$name provider IDs must not be empty');
        await load(subject, providerId);
      }
    },
  );
}
