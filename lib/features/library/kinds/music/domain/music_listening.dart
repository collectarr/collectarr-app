import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:flutter/foundation.dart';

/// A completed listening event attached to one local Music library entry.
///
/// The local entry is the complete editable record and the stable owner of
/// personal activity. Catalog provenance is deliberately not repeated here.
@immutable
final class MusicListenEvent {
  const MusicListenEvent({
    required this.id,
    required this.libraryEntryRef,
    required this.listenedAt,
    this.startedAt,
    this.finishedAt,
    this.location,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final LibraryEntryRef libraryEntryRef;
  final DateTime listenedAt;
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
        'library_entry_ref': libraryEntryRef.toJson(),
        'listened_at': listenedAt.toIso8601String(),
        if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };

  /// Payload for Sync, where the event ID is carried by the outer entity key.
  Map<String, dynamic> toSyncPayload() {
    final payload = toJson()..remove('id');
    return payload;
  }

  factory MusicListenEvent.fromJson(Map<String, dynamic> json) {
    final rawEntry = json['library_entry_ref'];
    if (rawEntry is! Map) {
      throw const FormatException(
          'MusicListenEvent requires library_entry_ref');
    }
    return MusicListenEvent(
      id: (json['id'] as String?) ?? '',
      libraryEntryRef: LibraryEntryRef.fromJson(
        Map<String, Object?>.from(rawEntry),
      ),
      listenedAt: json['listened_at'] != null
          ? DateTime.parse(json['listened_at'] as String)
          : DateTime.now(),
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
