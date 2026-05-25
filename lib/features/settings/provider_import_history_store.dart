import 'dart:convert';

import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderImportHistoryStore {
  const ProviderImportHistoryStore();

  static const _key = 'collectarr.provider_import.history';
  static const _maxEntries = 30;

  Future<List<ProviderImportHistoryEntry>> read({
    ProviderImportId? provider,
    int? limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    final entries = ProviderImportHistoryEntry.decodeList(raw)
        .where((entry) => provider == null || entry.provider == provider)
        .toList(growable: false)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    if (limit == null || entries.length <= limit) {
      return entries;
    }
    return entries.take(limit).toList(growable: false);
  }

  Future<void> append(ProviderImportHistoryEntry entry) async {
    final existing = await read();
    final next = [entry, ...existing]
        .take(_maxEntries)
        .toList(growable: false);
    await _write(next);
  }

  Future<void> clear({ProviderImportId? provider}) async {
    if (provider == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      return;
    }
    final existing = await read();
    await _write([
      for (final entry in existing)
        if (entry.provider != provider) entry,
    ]);
  }

  Future<void> _write(List<ProviderImportHistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final entry in entries) entry.toJson()]),
    );
  }
}