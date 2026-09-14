import 'package:flutter_test/flutter_test.dart';

typedef TypedContractCheck<TSubject> = void Function(TSubject subject);

void defineTypedContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required List<TypedContractCheck<TSubject>> checks,
}) {
  test(name, () {
    final subject = create();
    for (final check in checks) {
      check(subject);
    }
  });
}

void defineAsyncTypedContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Future<void> Function(TSubject subject) check,
}) {
  test(name, () async {
    await check(create());
  });
}

void expectContract(bool condition, String reason) {
  expect(condition, isTrue, reason: reason);
}

void expectNonEmpty(String value, String reason) {
  expect(value.trim(), isNotEmpty, reason: reason);
}

void expectUnique(Iterable<String> values, String reason) {
  final valueList = values.toList(growable: false);
  expect(valueList, hasLength(valueList.toSet().length), reason: reason);
}

void expectSame<T>(T actual, T expected, String reason) {
  expect(actual, equals(expected), reason: reason);
}
