import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:flutter/foundation.dart';

enum ProviderEntryStatus {
  planning,
  current,
  completed,
  paused,
  dropped,
  repeating,
}

@immutable
final class ProviderPersonalEntry {
  const ProviderPersonalEntry({
    required this.provider,
    required this.remoteItemId,
    this.remoteEntryId,
    required this.kind,
    this.title,
    this.externalIds = const {},
    this.status,
    this.rating,
    this.progress,
    this.totalProgress,
    this.startedAt,
    this.completedAt,
    this.repeatCount = 0,
    this.remoteUpdatedAt,
    this.remoteRevision,
    this.notes,
    this.rawPayload = const {},
  });

  final ProviderId provider;
  final String remoteItemId;
  final String? remoteEntryId;
  final CatalogMediaKind kind;
  final String? title;
  final Map<String, String> externalIds;
  final ProviderEntryStatus? status;
  final double? rating;
  final int? progress;
  final int? totalProgress;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int repeatCount;
  final DateTime? remoteUpdatedAt;
  final String? remoteRevision;
  final String? notes;
  final Map<String, dynamic> rawPayload;

  Map<String, dynamic> toJson() => {
        'provider': provider.value,
        'remoteItemId': remoteItemId,
        if (remoteEntryId != null) 'remoteEntryId': remoteEntryId,
        'kind': kind.apiValue,
        if (title != null) 'title': title,
        'externalIds': externalIds,
        if (status != null) 'status': status!.name,
        if (rating != null) 'rating': rating,
        if (progress != null) 'progress': progress,
        if (totalProgress != null) 'totalProgress': totalProgress,
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        'repeatCount': repeatCount,
        if (remoteUpdatedAt != null)
          'remoteUpdatedAt': remoteUpdatedAt!.toIso8601String(),
        if (remoteRevision != null) 'remoteRevision': remoteRevision,
        if (notes != null) 'notes': notes,
      };

  factory ProviderPersonalEntry.fromJson(Map<String, dynamic> json) {
    return ProviderPersonalEntry(
      provider:
          ProviderId.fromValue(json['provider']?.toString()) ?? ProviderId.tmdb,
      remoteItemId: json['remoteItemId']?.toString() ?? '',
      remoteEntryId: json['remoteEntryId']?.toString(),
      kind: catalogMediaKindFromApiValue(json['kind']?.toString() ?? 'movie'),
      title: json['title']?.toString(),
      externalIds: Map<String, String>.from(
        (json['externalIds'] as Map?) ?? const {},
      ),
      status: json['status'] != null
          ? ProviderEntryStatus.values.asNameMap()[json['status'].toString()]
          : null,
      rating: (json['rating'] as num?)?.toDouble(),
      progress: json['progress'] as int?,
      totalProgress: json['totalProgress'] as int?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      repeatCount: (json['repeatCount'] as int?) ?? 0,
      remoteUpdatedAt: json['remoteUpdatedAt'] != null
          ? DateTime.tryParse(json['remoteUpdatedAt'].toString())
          : null,
      remoteRevision: json['remoteRevision']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
