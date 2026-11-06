import 'package:collectarr_app/core/sync/sync_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SyncAccountAccess resolve({
    bool serverHasAccounts = true,
    String? accountId,
    String? linkedAccountId,
  }) {
    return resolveSyncAccountAccess(
      serverHasAccounts: serverHasAccounts,
      accountId: accountId,
      linkedAccountId: linkedAccountId,
    );
  }

  test('a server without accounts uses the shared key', () {
    expect(
      resolve(serverHasAccounts: false, accountId: 'a'),
      SyncAccountAccess.sharedKey,
    );
  });

  test('an unlinked library without a sign-in uses the shared key', () {
    expect(resolve(), SyncAccountAccess.sharedKey);
  });

  test('the first sign-in links the library', () {
    expect(resolve(accountId: 'a'), SyncAccountAccess.linkAccount);
  });

  test('a linked library syncs with its account', () {
    expect(
      resolve(accountId: 'a', linkedAccountId: 'a'),
      SyncAccountAccess.account,
    );
  });

  test('a linked library never falls back to the shared key', () {
    expect(
      () => resolve(linkedAccountId: 'a'),
      throwsA(isA<SyncAccountException>()),
    );
    expect(
      () => resolve(serverHasAccounts: false, linkedAccountId: 'a'),
      throwsA(isA<SyncAccountException>()),
    );
  });

  test('a linked library refuses another account', () {
    expect(
      () => resolve(accountId: 'b', linkedAccountId: 'a'),
      throwsA(isA<SyncAccountException>()),
    );
  });
}
