import 'dart:convert';

import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TmdbPendingImportRecord {
  const TmdbPendingImportRecord({
    required this.localItemId,
    required this.entry,
    required this.createdAt,
    this.proposalServerId,
  });

  final String localItemId;
  final TmdbImportEntry entry;
  final DateTime createdAt;
  final String? proposalServerId;

  factory TmdbPendingImportRecord.fromJson(Map<String, dynamic> json) {
    final entryJson = json['entry'];
    return TmdbPendingImportRecord(
      localItemId: json['local_item_id'] as String? ?? '',
      entry: TmdbImportEntry.fromJson(
        entryJson is Map<String, dynamic>
            ? entryJson
            : entryJson is Map
                ? Map<String, dynamic>.from(entryJson)
                : const <String, dynamic>{},
      ),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      proposalServerId: json['proposal_server_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_item_id': localItemId,
      'entry': entry.toJson(),
      'created_at': createdAt.toUtc().toIso8601String(),
      if (proposalServerId != null) 'proposal_server_id': proposalServerId,
    };
  }
}

class TmdbPendingImportStore {
  const TmdbPendingImportStore();

  static const _key = 'collectarr.tmdb.pending_local_imports';

  Future<List<TmdbPendingImportRecord>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return [
      for (final value in decoded)
        if (value is Map<String, dynamic>)
          TmdbPendingImportRecord.fromJson(value)
        else if (value is Map)
          TmdbPendingImportRecord.fromJson(Map<String, dynamic>.from(value)),
    ];
  }

  Future<void> upsert(TmdbPendingImportRecord record) async {
    final existing = await read();
    final next = [
      record,
      for (final candidate in existing)
        if (candidate.localItemId != record.localItemId) candidate,
    ];
    await _write(next);
  }

  Future<void> remove(String localItemId) async {
    final existing = await read();
    await _write([
      for (final candidate in existing)
        if (candidate.localItemId != localItemId) candidate,
    ]);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _write(List<TmdbPendingImportRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final record in records) record.toJson()]),
    );
  }
}
