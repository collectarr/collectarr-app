import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MetadataProposalRecord {
  const MetadataProposalRecord({
    required this.localId,
    this.serverId,
    required this.provider,
    required this.query,
    this.title,
    required this.status,
    required this.source,
    required this.createdAt,
  });

  final String localId;
  final String? serverId;
  final String provider;
  final String query;
  final String? title;
  final String status;
  final String source;
  final DateTime createdAt;

  factory MetadataProposalRecord.fromJson(Map<String, dynamic> json) {
    return MetadataProposalRecord(
      localId: json['local_id'] as String? ?? '',
      serverId: json['server_id'] as String?,
      provider: json['provider'] as String? ?? 'unknown',
      query: json['query'] as String? ?? '',
      title: json['title'] as String?,
      status: json['status'] as String? ?? 'submitted',
      source: json['source'] as String? ?? 'App',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      'provider': provider,
      'query': query,
      if (title != null) 'title': title,
      'status': status,
      'source': source,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}

class MetadataProposalStore {
  const MetadataProposalStore();

  static const _key = 'collectarr.metadata_proposals.local_history';
  static const _maxRecords = 50;

  Future<List<MetadataProposalRecord>> read() async {
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
          MetadataProposalRecord.fromJson(value)
        else if (value is Map)
          MetadataProposalRecord.fromJson(Map<String, dynamic>.from(value)),
    ];
  }

  Future<void> recordResponse({
    required Map<String, dynamic> response,
    required String provider,
    required String query,
    required String source,
    String? title,
  }) async {
    await record(
      serverId: response['id']?.toString(),
      provider: provider,
      query: query,
      title: title,
      status: response['status']?.toString() ?? 'pending',
      source: source,
    );
  }

  Future<void> record({
    String? serverId,
    required String provider,
    required String query,
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
        provider: provider,
        query: query,
        title: _clean(title),
        status: status,
        source: source,
        createdAt: now,
      ),
      ...existing,
    ].take(_maxRecords).toList(growable: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final record in next) record.toJson()]),
    );
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
