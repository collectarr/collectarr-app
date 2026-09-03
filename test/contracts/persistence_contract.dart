import 'contract_test_helpers.dart';

void definePersistenceContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Map<String, dynamic> Function(TSubject subject) encode,
  required TSubject Function(Map<String, dynamic> payload) decode,
  required bool Function(TSubject left, TSubject right) equals,
}) {
  defineTypedContract<TSubject>(
    name: '$name persistence contract',
    create: create,
    checks: [
      (subject) {
        final payload = encode(subject);
        expectContract(
            payload.isNotEmpty, '$name persistence payload is empty');
        expectContract(
          equals(subject, decode(payload)),
          '$name persistence must preserve typed data',
        );
      },
    ],
  );
}
