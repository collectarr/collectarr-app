import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account_context.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:collectarr_app/features/providers/credentials/provider_credential_store.dart';
import 'package:collectarr_app/features/providers/credentials/secure_provider_credential_store.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
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
  return DriftProviderAccountStore(
    database: ref.watch(localDatabaseProvider),
    credentials: SecureProviderCredentialStore(),
  );
});

class DriftProviderAccountStore implements ProviderAccountStore {
  const DriftProviderAccountStore({
    required this.database,
    required this.credentials,
  });

  final LocalDatabase database;
  final ProviderCredentialStore credentials;

  @override
  Future<List<ProviderAccount>> getAllAccounts() async {
    final rows = await database.select(database.providerAccountsCache).get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<ProviderAccount?> getAccount(String id) async {
    final row = await (database.select(database.providerAccountsCache)
          ..where((account) => account.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> saveAccount(
    ProviderAccount account, {
    String? accessToken,
    Map<String, String>? credentials,
  }) async {
    await database.into(database.providerAccountsCache).insert(
          _toCompanion(account),
          mode: InsertMode.insertOrReplace,
        );
    if (accessToken != null) {
      await this.credentials.write(
            _accessTokenKey(account.id),
            accessToken,
          );
    }
    if (credentials != null) {
      await this.credentials.write(
            _credentialsKey(account.id),
            jsonEncode(credentials),
          );
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    await (database.delete(database.providerAccountsCache)
          ..where((account) => account.id.equals(id)))
        .go();
    await Future.wait([
      credentials.delete(_accessTokenKey(id)),
      credentials.delete(_credentialsKey(id)),
    ]);
  }

  @override
  Future<ProviderAccountContext?> getAccountContext(String id) async {
    final account = await getAccount(id);
    if (account == null) return null;

    final accessToken = await credentials.read(_accessTokenKey(id));
    final rawCredentials = await credentials.read(_credentialsKey(id));
    Map<String, String> accountCredentials = const {};
    if (rawCredentials != null && rawCredentials.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawCredentials);
        if (decoded is Map) {
          accountCredentials = Map<String, String>.from(decoded);
        }
      } catch (_) {}
    }

    return ProviderAccountContext(
      accountId: account.id,
      provider: account.provider,
      remoteAccountId: account.remoteAccountId,
      remoteHandle: account.remoteHandle,
      accessToken: accessToken,
      credentials: accountCredentials,
      syncPolicy: account.syncPolicy,
    );
  }

  ProviderAccount _fromRow(ProviderAccountsCacheData row) {
    final enabledCapabilities = _decodeStringSet(row.enabledCapabilitiesJson);
    final policyJson = _decodeMap(row.syncPolicyJson);
    return ProviderAccount(
      id: row.id,
      provider: ProviderId.fromValue(row.provider) ?? ProviderId.aniList,
      displayName: row.displayName,
      authType: ProviderAuthType.values.asNameMap()[row.authType] ??
          ProviderAuthType.accessToken,
      remoteAccountId: row.remoteAccountId,
      remoteHandle: row.remoteHandle,
      username: row.username,
      avatarUrl: row.avatarUrl,
      connectedAt: row.connectedAt,
      lastSyncAt: row.lastSyncAt,
      enabledCapabilities: enabledCapabilities,
      syncPolicy: ProviderSyncPolicy.fromJson(policyJson),
    );
  }

  ProviderAccountsCacheCompanion _toCompanion(ProviderAccount account) {
    return ProviderAccountsCacheCompanion.insert(
      id: account.id,
      provider: account.provider.value,
      displayName: account.displayName,
      authType: account.authType.name,
      remoteAccountId: Value(account.remoteAccountId),
      remoteHandle: Value(account.remoteHandle),
      username: Value(account.username),
      avatarUrl: Value(account.avatarUrl),
      connectedAt: Value(account.connectedAt),
      lastSyncAt: Value(account.lastSyncAt),
      enabledCapabilitiesJson: jsonEncode(account.enabledCapabilities.toList()),
      syncPolicyJson: jsonEncode(account.syncPolicy.toJson()),
    );
  }

  Set<String> _decodeStringSet(String raw) {
    final decoded = _decodeList(raw);
    return decoded.whereType<String>().toSet();
  }

  List<Object?> _decodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : const [];
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> _decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
    } catch (_) {
      return const {};
    }
  }

  String _accessTokenKey(String accountId) =>
      'collectarr.provider_account.$accountId.access_token';

  String _credentialsKey(String accountId) =>
      'collectarr.provider_account.$accountId.credentials';
}
