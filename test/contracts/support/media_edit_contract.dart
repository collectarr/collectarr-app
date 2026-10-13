import 'contract_test_helpers.dart';

void defineMediaEditContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) tabIds,
  required Iterable<String> Function(TSubject subject, String tabId) fieldIds,
}) {
  defineTypedContract<TSubject>(
    name: '$name media edit contract',
    create: create,
    checks: [
      (subject) {
        final tabs = tabIds(subject).toList(growable: false);
        expectContract(tabs.isNotEmpty, '$name media edit must expose a tab');
        expectUnique(tabs, '$name media edit tab IDs must be unique');
        for (final tabId in tabs) {
          expectUnique(fieldIds(subject, tabId),
              '$name media edit fields must be unique');
        }
      },
    ],
  );
}
