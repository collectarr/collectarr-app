import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:flutter/foundation.dart';

/// A completed listening event for a concrete Music Catalog Item.
///
/// Listening history is App-owned activity. It targets the catalog item and
/// can optionally record which owned copy was used.
@immutable
final class MusicListenEvent {
  const MusicListenEvent({
    required this.id,
    required this.catalogRef,
    required this.listenedAt,
    this.ownedRef,
    this.startedAt,
    this.finishedAt,
    this.location,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final CatalogEntityRef catalogRef;
  final DateTime listenedAt;
  final OwnedCopyRef? ownedRef;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? location;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'catalog_ref': catalogRef.toJson(),
        'listened_at': listenedAt.toIso8601String(),
        if (ownedRef != null) 'owned_ref': ownedRef!.toJson(),
        if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };

  factory MusicListenEvent.fromJson(Map<String, dynamic> json) {
    final rawCatalog = json['catalog_ref'];
    if (rawCatalog is! Map) {
      throw const FormatException('MusicListenEvent requires catalog_ref');
    }
    final rawOwned = json['owned_ref'];
    return MusicListenEvent(
      id: (json['id'] as String?) ?? '',
      catalogRef:
          CatalogEntityRef.fromJson(Map<String, Object?>.from(rawCatalog)),
      listenedAt: json['listened_at'] != null
          ? DateTime.parse(json['listened_at'] as String)
          : DateTime.now(),
      ownedRef: rawOwned is Map
          ? OwnedCopyRef.fromJson(Map<String, Object?>.from(rawOwned))
          : null,
      startedAt: _date(json['started_at']),
      finishedAt: _date(json['finished_at']),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _date(json['deleted_at']),
    );
  }
}

@immutable
final class MusicListeningStats {
  const MusicListeningStats({
    required this.listenCount,
    this.lastListened,
    this.history = const [],
  });

  final int listenCount;
  final DateTime? lastListened;
  final List<MusicListenEvent> history;

  factory MusicListeningStats.fromSessions(List<MusicListenEvent> sessions) {
    if (sessions.isEmpty) {
      return const MusicListeningStats(listenCount: 0);
    }
    final sorted = List<MusicListenEvent>.from(sessions)
      ..sort((a, b) => b.listenedAt.compareTo(a.listenedAt));
    return MusicListeningStats(
      listenCount: sessions.length,
      lastListened: sorted.first.listenedAt,
      history: sorted,
    );
  }
}

/// Read-only listening projection for one Catalog Item.
@immutable
final class MusicCatalogItemListeningSummary {
  const MusicCatalogItemListeningSummary({
    required this.catalogItemId,
    required this.totalListenCount,
    this.firstListened,
    this.lastListened,
    this.recentEvents = const [],
  });

  final String catalogItemId;
  final int totalListenCount;
  final DateTime? firstListened;
  final DateTime? lastListened;
  final List<MusicListenEvent> recentEvents;

  factory MusicCatalogItemListeningSummary.fromEvents({
    required String catalogItemId,
    required Iterable<MusicListenEvent> events,
  }) {
    final sorted = events.toList(growable: false)
      ..sort((a, b) => b.listenedAt.compareTo(a.listenedAt));
    final listenedTimes = [for (final event in sorted) event.listenedAt]
      ..sort();
    return MusicCatalogItemListeningSummary(
      catalogItemId: catalogItemId,
      totalListenCount: sorted.length,
      firstListened: listenedTimes.firstOrNull,
      lastListened: sorted.firstOrNull?.listenedAt,
      recentEvents: sorted,
    );
  }
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
