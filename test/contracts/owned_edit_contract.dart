import 'contract_test_helpers.dart';

void defineOwnedEditContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) tabIds,
  required Iterable<String> Function(TSubject subject, String tabId) fieldIds,
}) {
  defineTypedContract<TSubject>(
    name: '$name owned edit contract',
    create: create,
    checks: [
      (subject) {
        final tabs = tabIds(subject).toList(growable: false);
        expectContract(tabs.isNotEmpty, '$name owned edit needs a tab');
        expectUnique(tabs, '$name owned edit tab IDs must be unique');
        for (final tabId in tabs) {
          expectUnique(fieldIds(subject, tabId),
              '$name owned edit fields must be unique');
        }
      },
    ],
  );
}
