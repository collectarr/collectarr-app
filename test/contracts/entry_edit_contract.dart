import 'contract_test_helpers.dart';

void defineEntryEditContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) tabIds,
  required Iterable<String> Function(TSubject subject, String tabId) fieldIds,
}) {
  defineTypedContract<TSubject>(
    name: '$name entry edit contract',
    create: create,
    checks: [
      (subject) {
        final tabs = tabIds(subject).toList(growable: false);
        expectContract(tabs.isNotEmpty, '$name entry edit needs a tab');
        expectUnique(tabs, '$name entry edit tab IDs must be unique');
        for (final tabId in tabs) {
          expectUnique(fieldIds(subject, tabId),
              '$name entry edit fields must be unique');
        }
      },
    ],
  );
}
