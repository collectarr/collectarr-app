import 'dart:async';

import 'package:collectarr_app/features/providers/credentials/provider_credential_store.dart';
import 'package:collectarr_app/features/providers/credentials/secure_provider_credential_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Credentials and local account configuration for the TMDb personal import.
///
/// This belongs to the provider integration. Settings only hosts the controls
/// that edit it; it must not own provider protocol or import state.
class TmdbImportSettings {
  const TmdbImportSettings({
    this.apiKey = '',
    this.accountId = '',
    this.sessionId = '',
    this.isLoaded = false,
  });

  final String apiKey;
  final String accountId;
  final String sessionId;
  final bool isLoaded;

  bool get isConfigured =>
      apiKey.trim().isNotEmpty &&
      accountId.trim().isNotEmpty &&
      sessionId.trim().isNotEmpty;

  TmdbImportSettings copyWith({
    String? apiKey,
    String? accountId,
    String? sessionId,
    bool? isLoaded,
  }) {
    return TmdbImportSettings(
      apiKey: apiKey ?? this.apiKey,
      accountId: accountId ?? this.accountId,
      sessionId: sessionId ?? this.sessionId,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

final class TmdbImportSettingsStore {
  TmdbImportSettingsStore({ProviderCredentialStore? secureStore})
      : _secureStore = secureStore ?? SecureProviderCredentialStore();

  static const _apiKeyKey = 'collectarr.tmdb_import.api_key';
  static const _accountIdKey = 'collectarr.tmdb_import.account_id';
  static const _sessionIdKey = 'collectarr.tmdb_import.session_id';
  static const _secureApiKeyKey =
      'collectarr.provider_creds.tmdb_import.api_key';
  static const _secureSessionIdKey =
      'collectarr.provider_creds.tmdb_import.session_id';

  final ProviderCredentialStore _secureStore;

  Future<TmdbImportSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await _readSecret(
      secureKey: _secureApiKeyKey,
      legacyPreferenceKey: _apiKeyKey,
      prefs: prefs,
    );
    final sessionId = await _readSecret(
      secureKey: _secureSessionIdKey,
      legacyPreferenceKey: _sessionIdKey,
      prefs: prefs,
    );
    return TmdbImportSettings(
      apiKey: apiKey,
      accountId: prefs.getString(_accountIdKey) ?? '',
      sessionId: sessionId,
      isLoaded: true,
    );
  }

  Future<void> write(TmdbImportSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStore.write(_secureApiKeyKey, settings.apiKey.trim());
    await _secureStore.write(_secureSessionIdKey, settings.sessionId.trim());
    await prefs.setString(_accountIdKey, settings.accountId.trim());
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_sessionIdKey);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStore.delete(_secureApiKeyKey);
    await _secureStore.delete(_secureSessionIdKey);
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_accountIdKey);
    await prefs.remove(_sessionIdKey);
  }

  Future<String> _readSecret({
    required String secureKey,
    required String legacyPreferenceKey,
    required SharedPreferences prefs,
  }) async {
    final secureValue = await _secureStore.read(secureKey);
    if (secureValue != null) {
      await prefs.remove(legacyPreferenceKey);
      return secureValue;
    }

    final legacyValue = prefs.getString(legacyPreferenceKey)?.trim() ?? '';
    if (legacyValue.isNotEmpty) {
      await _secureStore.write(secureKey, legacyValue);
    }
    await prefs.remove(legacyPreferenceKey);
    return legacyValue;
  }
}

final tmdbImportSettingsStoreProvider =
    Provider<TmdbImportSettingsStore>((ref) {
  return TmdbImportSettingsStore(
    secureStore: ref.watch(secureProviderCredentialStoreProvider),
  );
});

final tmdbImportSettingsProvider =
    NotifierProvider<TmdbImportSettingsNotifier, TmdbImportSettings>(
  TmdbImportSettingsNotifier.new,
);

final class TmdbImportSettingsNotifier extends Notifier<TmdbImportSettings> {
  @override
  TmdbImportSettings build() {
    unawaited(_loadInitial());
    return const TmdbImportSettings();
  }

  Future<void> _loadInitial() async {
    final next = await ref.read(tmdbImportSettingsStoreProvider).read();
    if (!state.isLoaded) {
      state = next;
    }
  }

  Future<void> save({
    required String apiKey,
    required String accountId,
    required String sessionId,
  }) async {
    final next = TmdbImportSettings(
      apiKey: apiKey.trim(),
      accountId: accountId.trim(),
      sessionId: sessionId.trim(),
      isLoaded: true,
    );
    state = next;
    await ref.read(tmdbImportSettingsStoreProvider).write(next);
  }

  Future<void> reset() async {
    await ref.read(tmdbImportSettingsStoreProvider).reset();
    state = const TmdbImportSettings(isLoaded: true);
  }
}
