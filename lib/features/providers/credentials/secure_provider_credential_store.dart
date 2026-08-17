import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/bgg_credentials.dart';
import 'models/comicvine_credentials.dart';
import 'models/hardcover_credentials.dart';
import 'models/igdb_credentials.dart';
import 'models/tmdb_credentials.dart';
import 'provider_credential_store.dart';

/// Secure, local-only storage for BYOK provider credentials.
///
/// Under no circumstances should values from this store be synced,
/// exported, sent to Collectarr Core, or persisted in normal DB tables.
class SecureProviderCredentialStore implements ProviderCredentialStore {
  SecureProviderCredentialStore({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _keyPrefix = 'collectarr.provider_creds.';

  static const String comicVineKey = '${_keyPrefix}comicvine';
  static const String hardcoverKey = '${_keyPrefix}hardcover';
  static const String tmdbKey = '${_keyPrefix}tmdb';
  static const String bggKey = '${_keyPrefix}bgg';
  static const String igdbKey = '${_keyPrefix}igdb';

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (_) {
      return false;
    }
  }

  // ─── Comic Vine ───

  Future<ComicVineCredentials?> getComicVineCredentials() async {
    final raw = await read(comicVineKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return ComicVineCredentials.fromJson(Map<String, dynamic>.from(json));
      }
      return ComicVineCredentials(apiKey: raw.trim());
    } catch (_) {
      return ComicVineCredentials(apiKey: raw.trim());
    }
  }

  Future<void> setComicVineCredentials(ComicVineCredentials creds) async {
    await write(comicVineKey, jsonEncode(creds.toJson()));
  }

  Future<void> clearComicVineCredentials() async {
    await delete(comicVineKey);
  }

  // ─── Hardcover ───

  Future<HardcoverCredentials?> getHardcoverCredentials() async {
    final raw = await read(hardcoverKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return HardcoverCredentials.fromJson(Map<String, dynamic>.from(json));
      }
      return HardcoverCredentials(apiKey: raw.trim());
    } catch (_) {
      return HardcoverCredentials(apiKey: raw.trim());
    }
  }

  Future<void> setHardcoverCredentials(HardcoverCredentials creds) async {
    await write(hardcoverKey, jsonEncode(creds.toJson()));
  }

  Future<void> clearHardcoverCredentials() async {
    await delete(hardcoverKey);
  }

  // ─── TMDb ───

  Future<TmdbCredentials?> getTmdbCredentials() async {
    final raw = await read(tmdbKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return TmdbCredentials.fromJson(Map<String, dynamic>.from(json));
      }
      return TmdbCredentials(readAccessToken: raw.trim());
    } catch (_) {
      return TmdbCredentials(readAccessToken: raw.trim());
    }
  }

  Future<void> setTmdbCredentials(TmdbCredentials creds) async {
    await write(tmdbKey, jsonEncode(creds.toJson()));
  }

  Future<void> clearTmdbCredentials() async {
    await delete(tmdbKey);
  }

  // ─── BGG ───

  Future<BggCredentials?> getBggCredentials() async {
    final raw = await read(bggKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return BggCredentials.fromJson(Map<String, dynamic>.from(json));
      }
      return BggCredentials(apiToken: raw.trim());
    } catch (_) {
      return BggCredentials(apiToken: raw.trim());
    }
  }

  Future<void> setBggCredentials(BggCredentials creds) async {
    await write(bggKey, jsonEncode(creds.toJson()));
  }

  Future<void> clearBggCredentials() async {
    await delete(bggKey);
  }

  // ─── IGDB ───

  Future<IgdbCredentials?> getIgdbCredentials() async {
    final raw = await read(igdbKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return IgdbCredentials.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setIgdbCredentials(IgdbCredentials creds) async {
    await write(igdbKey, jsonEncode(creds.toJson()));
  }

  Future<void> clearIgdbCredentials() async {
    await delete(igdbKey);
  }

  // ─── Bulk Clearing ───

  Future<void> clearAll() async {
    await Future.wait([
      clearComicVineCredentials(),
      clearHardcoverCredentials(),
      clearTmdbCredentials(),
      clearBggCredentials(),
      clearIgdbCredentials(),
    ]);
  }

  /// Utility to mask a secret value for safe display in settings UI (e.g. `••••••••abcd`).
  static String maskSecret(String? secret, {int visibleSuffixLength = 4}) {
    if (secret == null || secret.isEmpty) return '';
    final trimmed = secret.trim();
    if (trimmed.length <= visibleSuffixLength) {
      return '•' * trimmed.length;
    }
    final prefix = '•' * (trimmed.length - visibleSuffixLength);
    final suffix = trimmed.substring(trimmed.length - visibleSuffixLength);
    return '$prefix$suffix';
  }
}
