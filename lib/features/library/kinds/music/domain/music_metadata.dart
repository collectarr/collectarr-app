import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:flutter/foundation.dart';

@immutable
class MusicTrackMetadata {
  const MusicTrackMetadata({
    this.disc = 1,
    this.side,
    required this.number,
    required this.title,
    this.durationSeconds,
    this.artist,
  });

  final int disc;
  final String? side;
  final String number;
  final String title;
  final int? durationSeconds;
  final String? artist;

  Map<String, dynamic> toJson() => {
        'disc': disc,
        if (side != null) 'side': side,
        'number': number,
        'title': title,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        if (artist != null) 'artist': artist,
      };

  factory MusicTrackMetadata.fromJson(Map<String, dynamic> json) {
    return MusicTrackMetadata(
      disc: json['disc'] as int? ?? 1,
      side: json['side'] as String?,
      number: (json['number'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      durationSeconds: json['duration_seconds'] as int?,
      artist: json['artist'] as String?,
    );
  }
}

@immutable
class MusicCredit {
  const MusicCredit({
    required this.name,
    required this.role,
    this.instrument,
  });

  final String name;
  final String role; // performer, composer, producer, engineer, musician
  final String? instrument;

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        if (instrument != null) 'instrument': instrument,
      };

  factory MusicCredit.fromJson(Map<String, dynamic> json) {
    return MusicCredit(
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      instrument: json['instrument'] as String?,
    );
  }
}

@immutable
class MusicReleaseMetadata {
  const MusicReleaseMetadata({
    required this.id,
    required this.title,
    this.catalogNumber,
    this.format,
    this.country,
    this.releaseLanguage,
    this.mediaOrDiscCount,
    this.barcode,
    this.label,
    this.releaseDate,
    this.tracks = const [],
  });

  final String id;
  final String title;
  final String? catalogNumber;
  final String? format;
  final String? country;
  final String? releaseLanguage;
  final int? mediaOrDiscCount;
  final String? barcode;
  final String? label;
  final DateTime? releaseDate;
  final List<MusicTrackMetadata> tracks;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (format != null) 'format': format,
        if (country != null) 'country': country,
        if (releaseLanguage != null) 'release_language': releaseLanguage,
        if (mediaOrDiscCount != null) 'media_or_disc_count': mediaOrDiscCount,
        if (barcode != null) 'barcode': barcode,
        if (label != null) 'label': label,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (tracks.isNotEmpty) 'tracks': tracks.map((e) => e.toJson()).toList(),
      };

  factory MusicReleaseMetadata.fromJson(Map<String, dynamic> json) {
    return MusicReleaseMetadata(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      catalogNumber: json['catalog_number'] as String?,
      format: json['format'] as String?,
      country: json['country'] as String?,
      releaseLanguage: json['release_language'] as String?,
      mediaOrDiscCount: json['media_or_disc_count'] as int?,
      barcode: json['barcode'] as String?,
      label: json['label'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map(
                  (e) => MusicTrackMetadata.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

typedef MusicMetadata = MusicCatalogMetadata;

@immutable
class MusicCatalogMetadata implements LibraryKindMetadataRuntime {
  const MusicCatalogMetadata({
    required this.title,
    this.artist,
    this.originalReleaseDate,
    this.recordingDate,
    this.studio,
    this.isLive = false,
    this.genres = const [],
    this.credits = const [],
    this.releases = const [],
    this.synopsis,
  });

  @override
  CatalogMediaKind get mediaKind => CatalogMediaKind.music;

  @override
  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? artist;
  final DateTime? originalReleaseDate;
  final DateTime? recordingDate;
  final String? studio;
  final bool isLive;
  final List<String> genres;
  final List<MusicCredit> credits;
  final List<MusicReleaseMetadata> releases;
  final String? synopsis;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (artist != null) 'artist': artist,
        if (originalReleaseDate != null)
          'original_release_date': originalReleaseDate!.toIso8601String(),
        if (recordingDate != null)
          'recording_date': recordingDate!.toIso8601String(),
        if (studio != null) 'studio': studio,
        if (isLive) 'is_live': true,
        if (genres.isNotEmpty) 'genres': genres,
        if (credits.isNotEmpty)
          'credits': credits.map((e) => e.toJson()).toList(),
        if (releases.isNotEmpty)
          'releases': releases.map((e) => e.toJson()).toList(),
        if (synopsis != null) 'synopsis': synopsis,
      };

  factory MusicCatalogMetadata.fromJson(Map<String, dynamic> json) {
    return MusicCatalogMetadata(
      title: (json['title'] as String?) ?? '',
      artist: json['artist'] as String?,
      originalReleaseDate: json['original_release_date'] != null
          ? DateTime.tryParse(json['original_release_date'] as String)
          : null,
      recordingDate: json['recording_date'] != null
          ? DateTime.tryParse(json['recording_date'] as String)
          : null,
      studio: json['studio'] as String?,
      isLive: json['is_live'] as bool? ?? false,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      credits: (json['credits'] as List<dynamic>?)
              ?.map((e) => MusicCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      releases: (json['releases'] as List<dynamic>?)
              ?.map((e) =>
                  MusicReleaseMetadata.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      synopsis: (json['synopsis'] ?? json['description']) as String?,
    );
  }
}

@immutable
class ListeningSession {
  const ListeningSession({
    required this.id,
    required this.itemId,
    this.releaseId,
    required this.listenedAt,
    this.location,
    this.notes,
  });

  final String id;
  final String itemId;
  final String? releaseId;
  final DateTime listenedAt;
  final String? location;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        if (releaseId != null) 'release_id': releaseId,
        'listened_at': listenedAt.toIso8601String(),
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      };

  factory ListeningSession.fromJson(Map<String, dynamic> json) {
    return ListeningSession(
      id: (json['id'] as String?) ?? '',
      itemId: (json['item_id'] as String?) ?? '',
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
class MusicListeningStats {
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
