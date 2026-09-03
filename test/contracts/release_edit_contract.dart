import 'contract_test_helpers.dart';

void defineReleaseEditContract<TSubject>({
  required String name,
  required TSubject Function() create,
  required Iterable<String> Function(TSubject subject) tabIds,
  required Iterable<String> Function(TSubject subject, String tabId) fieldIds,
}) {
  defineTypedContract<TSubject>(
    name: '$name release edit contract',
    create: create,
    checks: [
      (subject) {
        final tabs = tabIds(subject).toList(growable: false);
        expectContract(tabs.isNotEmpty, '$name release edit must expose a tab');
        expectUnique(tabs, '$name release edit tab IDs must be unique');
        for (final tabId in tabs) {
          expectUnique(fieldIds(subject, tabId),
              '$name release edit fields must be unique');
        }
      },
    ],
  );
}
