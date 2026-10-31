import 'dart:convert';

import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetadataProposalRecord {
  const MetadataProposalRecord({
    required this.localId,
    this.serverId,
    required this.kind,
    this.title,
    required this.status,
    required this.source,
    required this.createdAt,
  });

  final String localId;
  final String? serverId;
  final String kind;
  final String? title;
  final String status;
  final String source;
  final DateTime createdAt;

  factory MetadataProposalRecord.fromJson(JsonMap json) {
    return MetadataProposalRecord(
      localId: json['local_id'] as String? ?? '',
      serverId: json['server_id'] as String?,
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String?,
      status: json['status'] as String? ?? 'pending',
      source: json['source'] as String? ?? 'App',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  JsonMap toJson() => {
        'local_id': localId,
        if (serverId != null) 'server_id': serverId,
        'kind': kind,
        if (title != null) 'title': title,
        'status': status,
        'source': source,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

class MetadataProposalStore {
  const MetadataProposalStore();

  static const _key = 'collectarr.catalog_item_proposals.local_history.v1';
  static const _maxRecords = 50;

  Future<List<MetadataProposalRecord>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final value in decoded)
        if (value is JsonMap)
          MetadataProposalRecord.fromJson(value)
        else if (value is Map)
          MetadataProposalRecord.fromJson(JsonMap.from(value)),
    ];
  }

  Future<void> recordResponse({
    required JsonMap response,
    required String kind,
    required String source,
    String? title,
  }) {
    return record(
      serverId: response['id']?.toString(),
      kind: kind,
      title: title,
      status: response['status']?.toString() ?? 'pending',
      source: source,
    );
  }

  Future<void> record({
    String? serverId,
    required String kind,
    String? title,
    required String status,
    required String source,
  }) async {
    final existing = await read();
    final now = DateTime.now().toUtc();
    final next = [
      MetadataProposalRecord(
        localId: now.microsecondsSinceEpoch.toString(),
        serverId: _clean(serverId),
        kind: kind,
        title: _clean(title),
        status: status,
        source: source,
        createdAt: now,
      ),
      ...existing,
    ].take(_maxRecords).toList(growable: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode([for (final record in next) record.toJson()]));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
