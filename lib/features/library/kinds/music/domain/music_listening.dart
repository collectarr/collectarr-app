import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:flutter/foundation.dart';

/// A completed listening event for a Music entity.
///
/// This is intentionally Music-owned. Listening is not a generic watch
/// session with renamed labels: Music can target a release group, release,
/// medium, or track and can optionally identify the physical owned copy.
@immutable
final class MusicListenEvent {
  const MusicListenEvent({
    required this.id,
    required this.targetRef,
    required this.releaseGroupId,
    required this.releaseId,
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
  final CatalogEntityRef targetRef;
  final String releaseGroupId;
  final String releaseId;
  final DateTime listenedAt;
  final OwnedItemRef? ownedRef;
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
        'target_ref': targetRef.toJson(),
        'release_group_id': releaseGroupId,
        'release_id': releaseId,
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
    final rawTarget = json['target_ref'];
    if (rawTarget is! Map) {
      throw const FormatException('MusicListenEvent requires target_ref');
    }
    final targetRef =
        CatalogEntityRef.fromJson(Map<String, Object?>.from(rawTarget));
    if (targetRef.mediaKind != CatalogMediaKind.music) {
      throw FormatException(
        'MusicListenEvent target_ref must be music, got ${targetRef.kind}',
      );
    }
    final rawOwned = json['owned_ref'];
    final ownedRef = rawOwned is Map
        ? OwnedItemRef.fromJson(Map<String, Object?>.from(rawOwned))
        : null;
    return MusicListenEvent(
      id: (json['id'] as String?) ?? '',
      targetRef: targetRef,
      releaseGroupId: (json['release_group_id'] as String?) ??
          targetRef.rootId ??
          targetRef.id,
      releaseId: _requiredText(json['release_id'], 'release_id'),
      listenedAt: json['listened_at'] != null
          ? DateTime.parse(json['listened_at'] as String)
          : DateTime.now(),
      ownedRef: ownedRef,
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

/// Read-only listening projection for one concrete Music release.
///
/// This is derived from listening events and is never persisted as a second
/// lifecycle source of truth.
@immutable
final class MusicReleaseTrackingSummary {
  const MusicReleaseTrackingSummary({
    required this.releaseId,
    required this.listenCount,
    this.firstListened,
    this.lastListened,
    this.recentEvents = const [],
  });

  final String releaseId;
  final int listenCount;
  final DateTime? firstListened;
  final DateTime? lastListened;
  final List<MusicListenEvent> recentEvents;

  bool get hasBeenListened => listenCount > 0;
}

/// Read-only aggregate for a Music release group.
///
/// Group tracking is intentionally computed from event history. There is no
/// writable group-level tracking row.
@immutable
final class MusicReleaseGroupTrackingSummary {
  const MusicReleaseGroupTrackingSummary({
    required this.releaseGroupId,
    required this.totalListenCount,
    required this.totalReleases,
    required this.releaseBreakdown,
    this.firstListened,
    this.lastListened,
    this.recentEvents = const [],
  });

  final String releaseGroupId;
  final int totalListenCount;
  final int totalReleases;
  final DateTime? firstListened;
  final DateTime? lastListened;
  final List<MusicReleaseTrackingSummary> releaseBreakdown;
  final List<MusicListenEvent> recentEvents;

  int get listenedReleaseCount =>
      releaseBreakdown.where((release) => release.hasBeenListened).length;

  List<String> get listenedReleases => [
        for (final release in releaseBreakdown)
          if (release.hasBeenListened) release.releaseId,
      ];

  factory MusicReleaseGroupTrackingSummary.fromEvents({
    required String releaseGroupId,
    required Iterable<MusicListenEvent> events,
    required Iterable<String> releaseIds,
  }) {
    final allEvents = events.toList(growable: false)
      ..sort((a, b) => b.listenedAt.compareTo(a.listenedAt));
    final ids = {...releaseIds, ..._releaseIdsFromEvents(allEvents)}.toList()
      ..sort();
    final byRelease = <String, List<MusicListenEvent>>{
      for (final id in ids) id: <MusicListenEvent>[],
    };
    for (final event in allEvents) {
      final releaseId = _eventReleaseId(event);
      if (releaseId != null) {
        byRelease.putIfAbsent(releaseId, () => <MusicListenEvent>[]).add(event);
      }
    }
    final breakdown = [
      for (final id in byRelease.keys) _releaseSummary(id, byRelease[id]!),
    ];
    final listenedTimes = [
      for (final event in allEvents) event.listenedAt,
    ]..sort();
    return MusicReleaseGroupTrackingSummary(
      releaseGroupId: releaseGroupId,
      totalListenCount: allEvents.length,
      totalReleases: ids.length,
      firstListened: listenedTimes.firstOrNull,
      lastListened: allEvents.firstOrNull?.listenedAt,
      releaseBreakdown: breakdown,
      recentEvents: allEvents,
    );
  }
}

MusicReleaseTrackingSummary _releaseSummary(
  String releaseId,
  List<MusicListenEvent> events,
) {
  final sorted = List<MusicListenEvent>.from(events)
    ..sort((a, b) => b.listenedAt.compareTo(a.listenedAt));
  final times = [for (final event in sorted) event.listenedAt]..sort();
  return MusicReleaseTrackingSummary(
    releaseId: releaseId,
    listenCount: sorted.length,
    firstListened: times.firstOrNull,
    lastListened: sorted.firstOrNull?.listenedAt,
    recentEvents: sorted,
  );
}

Iterable<String> _releaseIdsFromEvents(
    Iterable<MusicListenEvent> events) sync* {
  for (final event in events) {
    final releaseId = _eventReleaseId(event);
    if (releaseId != null) yield releaseId;
  }
}

String? _eventReleaseId(MusicListenEvent event) {
  return event.releaseId;
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

String _requiredText(Object? value, String field) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    throw FormatException('MusicListenEvent requires $field');
  }
  return text;
}
