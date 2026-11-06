import 'package:shared_preferences/shared_preferences.dart';

/// How this device reaches its library on the sync server.
enum SyncAccountAccess {
  /// The shared key's partition: a server without accounts, or no sign-in yet.
  sharedKey,

  /// The signed-in account's partition, which this library is already linked to.
  account,

  /// The signed-in account's partition, linking this library to it first.
  linkAccount,
}

/// Why this library cannot sync right now, in words for the user.
class SyncAccountException implements Exception {
  const SyncAccountException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Decides how to sync. A linked library only ever syncs with its own account,
/// so one person's collection never reaches another's or the shared partition.
SyncAccountAccess resolveSyncAccountAccess({
  required bool serverHasAccounts,
  required String? accountId,
  required String? linkedAccountId,
}) {
  if (!serverHasAccounts) {
    if (linkedAccountId != null) {
      throw const SyncAccountException(
        'This library is linked to an account, but this sync server does not '
        'accept accounts.',
      );
    }
    return SyncAccountAccess.sharedKey;
  }
  if (accountId == null) {
    if (linkedAccountId != null) {
      throw const SyncAccountException('Sign in to keep syncing this library.');
    }
    return SyncAccountAccess.sharedKey;
  }
  if (linkedAccountId == null) return SyncAccountAccess.linkAccount;
  if (linkedAccountId != accountId) {
    throw const SyncAccountException(
      'This library is linked to another account. Sign in with that account, '
      'or use Clear Database in the menu to start over with this one.',
    );
  }
  return SyncAccountAccess.account;
}

/// Remembers which account this device's library belongs to.
class SyncAccountStore {
  static const _key = 'collectarr.sync.account_id';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> write(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, accountId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
