import 'dart:convert';

enum ProviderImportId {
  tmdb,
}

extension ProviderImportIdX on ProviderImportId {
  String get storageValue {
    return switch (this) {
      ProviderImportId.tmdb => 'tmdb',
    };
  }

  String get label {
    return switch (this) {
      ProviderImportId.tmdb => 'TMDB',
    };
  }

  static ProviderImportId? fromStorageValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'tmdb' => ProviderImportId.tmdb,
      _ => null,
    };
  }
}

enum ProviderImportAvailability {
  available,
  comingSoon,
}

class ProviderImportDescriptor {
  const ProviderImportDescriptor({
    required this.id,
    required this.title,
    required this.summary,
    required this.supportsAccountSync,
    required this.supportsFileImport,
    this.availability = ProviderImportAvailability.available,
  });

  final ProviderImportId id;
  final String title;
  final String summary;
  final bool supportsAccountSync;
  final bool supportsFileImport;
  final ProviderImportAvailability availability;
}

const providerImportDescriptors = <ProviderImportDescriptor>[
  ProviderImportDescriptor(
    id: ProviderImportId.tmdb,
    title: 'TMDB',
    summary: 'Import rated and watchlist movies from TMDB account sync or TMDB export files.',
    supportsAccountSync: true,
    supportsFileImport: true,
  ),
];

enum ProviderImportHistoryStatus {
  success,
  failed,
}

extension ProviderImportHistoryStatusX on ProviderImportHistoryStatus {
  String get storageValue {
    return switch (this) {
      ProviderImportHistoryStatus.success => 'success',
      ProviderImportHistoryStatus.failed => 'failed',
    };
  }

  static ProviderImportHistoryStatus fromStorageValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'failed' => ProviderImportHistoryStatus.failed,
      _ => ProviderImportHistoryStatus.success,
    };
  }
}

class ProviderImportHistoryEntry {
  const ProviderImportHistoryEntry({
    required this.id,
    required this.provider,
    required this.status,
    required this.collectionLabel,
    required this.sourceLabel,
    required this.message,
    required this.createdAt,
    this.rows = 0,
    this.matched = 0,
    this.unmatched = 0,
    this.imported = 0,
    this.proposed = 0,
    this.keptLocal = 0,
  });

  final String id;
  final ProviderImportId provider;
  final ProviderImportHistoryStatus status;
  final String collectionLabel;
  final String sourceLabel;
  final String message;
  final DateTime createdAt;
  final int rows;
  final int matched;
  final int unmatched;
  final int imported;
  final int proposed;
  final int keptLocal;

  factory ProviderImportHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ProviderImportHistoryEntry(
      id: json['id'] as String? ?? '',
      provider: ProviderImportIdX.fromStorageValue(json['provider'] as String?) ??
          ProviderImportId.tmdb,
      status: ProviderImportHistoryStatusX.fromStorageValue(
        json['status'] as String?,
      ),
      collectionLabel: json['collection_label'] as String? ?? '',
      sourceLabel: json['source_label'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      rows: (json['rows'] as num?)?.toInt() ?? 0,
      matched: (json['matched'] as num?)?.toInt() ?? 0,
      unmatched: (json['unmatched'] as num?)?.toInt() ?? 0,
      imported: (json['imported'] as num?)?.toInt() ?? 0,
      proposed: (json['proposed'] as num?)?.toInt() ?? 0,
      keptLocal: (json['kept_local'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'provider': provider.storageValue,
      'status': status.storageValue,
      'collection_label': collectionLabel,
      'source_label': sourceLabel,
      'message': message,
      'created_at': createdAt.toUtc().toIso8601String(),
      'rows': rows,
      'matched': matched,
      'unmatched': unmatched,
      'imported': imported,
      'proposed': proposed,
      'kept_local': keptLocal,
    };
  }

  static List<ProviderImportHistoryEntry> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return [
      for (final value in decoded)
        if (value is Map<String, dynamic>)
          ProviderImportHistoryEntry.fromJson(value)
        else if (value is Map)
          ProviderImportHistoryEntry.fromJson(Map<String, dynamic>.from(value)),
    ];
  }
}