import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ProviderAccountStore {
  Future<List<ProviderAccount>> getAllAccounts();
  Future<ProviderAccount?> getAccount(String id);
  Future<void> saveAccount(ProviderAccount account,
      {String? accessToken, Map<String, String>? credentials});
  Future<void> deleteAccount(String id);
  Future<ProviderAccountContext?> getAccountContext(String id);
}

class InMemoryProviderAccountStore implements ProviderAccountStore {
  InMemoryProviderAccountStore([Map<String, ProviderAccount>? initialAccounts])
      : _accounts = initialAccounts ?? {};

  final Map<String, ProviderAccount> _accounts;
  final Map<String, String> _accessTokens = {};
  final Map<String, Map<String, String>> _credentials = {};

  @override
  Future<List<ProviderAccount>> getAllAccounts() async {
    return _accounts.values.toList();
  }

  @override
  Future<ProviderAccount?> getAccount(String id) async {
    return _accounts[id];
  }

  @override
  Future<void> saveAccount(
    ProviderAccount account, {
    String? accessToken,
    Map<String, String>? credentials,
  }) async {
    _accounts[account.id] = account;
    if (accessToken != null) {
      _accessTokens[account.id] = accessToken;
    }
    if (credentials != null) {
      _credentials[account.id] = credentials;
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    _accounts.remove(id);
    _accessTokens.remove(id);
    _credentials.remove(id);
  }

  @override
  Future<ProviderAccountContext?> getAccountContext(String id) async {
    final account = _accounts[id];
    if (account == null) return null;
    return ProviderAccountContext(
      accountId: account.id,
      provider: account.provider,
      remoteAccountId: account.remoteAccountId,
      remoteHandle: account.remoteHandle,
      accessToken: _accessTokens[account.id],
      credentials: _credentials[account.id] ?? const {},
      syncPolicy: account.syncPolicy,
    );
  }
}

final providerAccountStoreProvider = Provider<ProviderAccountStore>((ref) {
  return InMemoryProviderAccountStore();
});
