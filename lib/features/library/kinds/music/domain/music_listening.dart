import 'package:flutter/foundation.dart';

/// A completed listening event for a Music release group or release.
@immutable
final class ListeningSession {
  const ListeningSession({
    required this.id,
    required this.releaseGroupId,
    this.releaseId,
    required this.listenedAt,
    this.location,
    this.notes,
  });

  final String id;
  final String releaseGroupId;
  final String? releaseId;
  final DateTime listenedAt;
  final String? location;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'release_group_id': releaseGroupId,
        if (releaseId != null) 'release_id': releaseId,
        'listened_at': listenedAt.toIso8601String(),
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      };

  factory ListeningSession.fromJson(Map<String, dynamic> json) {
    return ListeningSession(
      id: (json['id'] as String?) ?? '',
      releaseGroupId:
          (json['release_group_id'] ?? json['item_id'] ?? '') as String,
      releaseId: json['release_id'] as String?,
      listenedAt: json['listened_at'] != null
          ? DateTime.parse(json['listened_at'] as String)
          : DateTime.now(),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
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
  final List<ListeningSession> history;

  factory MusicListeningStats.fromSessions(List<ListeningSession> sessions) {
    if (sessions.isEmpty) {
      return const MusicListeningStats(listenCount: 0);
    }
    final sorted = List<ListeningSession>.from(sessions)
      ..sort((a, b) => b.listenedAt.compareTo(a.listenedAt));
    return MusicListeningStats(
      listenCount: sessions.length,
      lastListened: sorted.first.listenedAt,
      history: sorted,
    );
  }
}
