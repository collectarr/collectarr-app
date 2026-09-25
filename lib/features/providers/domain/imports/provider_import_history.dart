import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

export 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

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

final class ProviderImportHistoryEntry {
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
  final ProviderId provider;
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
      provider: ProviderId.requireValue(json['provider'] as String?),
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
    if (decoded is! List) return const [];
    final entries = <ProviderImportHistoryEntry>[];
    for (var index = 0; index < decoded.length; index++) {
      final value = decoded[index];
      try {
        if (value is! Map) {
          throw FormatException(
            'Provider import history row must be a JSON object; '
            'found ${value.runtimeType}.',
          );
        }
        entries.add(
          ProviderImportHistoryEntry.fromJson(
            Map<String, dynamic>.from(value),
          ),
        );
      } catch (error, stackTrace) {
        final rowId = value is Map ? value['id'] : null;
        final provider = value is Map ? value['provider'] : null;
        logRecoverableError(
          source: 'provider_import_history',
          message:
              'Skipping invalid provider import history row index=$index id="$rowId" provider="$provider"; the stored entry was preserved.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return List.unmodifiable(entries);
  }
}
