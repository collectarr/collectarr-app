import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class TmdbImportSettingsStore {
  const TmdbImportSettingsStore();

  static const _apiKeyKey = 'collectarr.tmdb_import.api_key';
  static const _accountIdKey = 'collectarr.tmdb_import.account_id';
  static const _sessionIdKey = 'collectarr.tmdb_import.session_id';

  Future<TmdbImportSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    return TmdbImportSettings(
      apiKey: prefs.getString(_apiKeyKey) ?? '',
      accountId: prefs.getString(_accountIdKey) ?? '',
      sessionId: prefs.getString(_sessionIdKey) ?? '',
      isLoaded: true,
    );
  }

  Future<void> write(TmdbImportSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, settings.apiKey.trim());
    await prefs.setString(_accountIdKey, settings.accountId.trim());
    await prefs.setString(_sessionIdKey, settings.sessionId.trim());
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_accountIdKey);
    await prefs.remove(_sessionIdKey);
  }
}

final tmdbImportSettingsStoreProvider =
    Provider<TmdbImportSettingsStore>((ref) => const TmdbImportSettingsStore());

final tmdbImportSettingsProvider =
    NotifierProvider<TmdbImportSettingsNotifier, TmdbImportSettings>(
  TmdbImportSettingsNotifier.new,
);

class TmdbImportSettingsNotifier extends Notifier<TmdbImportSettings> {
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
