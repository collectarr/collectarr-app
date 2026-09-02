import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
    this.trackCount,
    this.tracks = const [],
    this.creators = const [],
    this.links = const [],
    this.synopsis,
    this.series,
    this.music,
    this.publishing,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.packaging,
    this.recordLabel,
    this.barcode,
    this.variant,
    this.country,
    this.language,
    this.rawPayload = const <String, dynamic>{},
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
  final int? trackCount;
  final List<CatalogTrackDto> tracks;
  final List<Map<String, dynamic>> creators;
  final List<TrailerLink> links;
  final String? synopsis;
  final CatalogSeriesDetailsDto? series;
  final Map<String, dynamic>? music;
  final CatalogPublishingDetailsDto? publishing;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final String? packaging;
  final String? recordLabel;
  final String? barcode;
  final String? variant;
  final String? country;
  final String? language;
  final Map<String, dynamic> rawPayload;

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'title': title,
        if (artist != null) ...{
          'artist': artist,
          'series_title': artist,
        },
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
        if (trackCount != null) 'track_count': trackCount,
        if (tracks.isNotEmpty) 'tracks': tracks.map((e) => e.toJson()).toList(),
        if (creators.isNotEmpty) 'creators': creators,
        if (series != null) 'series': series!.toJson(),
        if (music != null && music!.isNotEmpty) ...{
          'music': music!,
          ...music!,
        },
        if (publishing != null && publishing!.hasData) ...{
          'publishing': publishing!.toJson(),
          ...publishing!.toJson(),
        },
        if (editionTitle != null) 'edition_title': editionTitle,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (publisher != null) 'publisher': publisher,
        if (packaging != null) 'packaging': packaging,
        if (recordLabel != null) 'record_label': recordLabel,
        if (barcode != null) 'barcode': barcode,
        if (variant != null) 'variant': variant,
        if (country != null) 'country': country,
        if (language != null) 'language': language,
        if (links.isNotEmpty) ...{
          if (links.any((l) => l.isTrailerLink))
            'trailer_urls': links
                .where((l) => l.isTrailerLink)
                .map((e) => e.toJson())
                .toList(),
          if (links.any((l) => l.isExternalLink))
            'external_links': links
                .where((l) => l.isExternalLink)
                .map((e) => e.toJson())
                .toList(),
        },
        if (synopsis != null) 'synopsis': synopsis,
      };

  MusicCatalogMetadata copyWith({
    String? title,
    String? artist,
    DateTime? originalReleaseDate,
    DateTime? recordingDate,
    String? studio,
    bool? isLive,
    List<String>? genres,
    List<MusicCredit>? credits,
    List<MusicReleaseMetadata>? releases,
    int? trackCount,
    List<CatalogTrackDto>? tracks,
    List<Map<String, dynamic>>? creators,
    List<TrailerLink>? links,
    String? synopsis,
    CatalogSeriesDetailsDto? series,
    Map<String, dynamic>? music,
    CatalogPublishingDetailsDto? publishing,
    String? editionTitle,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? packaging,
    String? recordLabel,
    String? barcode,
    String? variant,
    String? country,
    String? language,
  }) {
    return MusicCatalogMetadata(
      title: title ?? this.title,
      rawPayload: rawPayload,
      artist: artist ?? this.artist,
      originalReleaseDate: originalReleaseDate ?? this.originalReleaseDate,
      recordingDate: recordingDate ?? this.recordingDate,
      studio: studio ?? this.studio,
      isLive: isLive ?? this.isLive,
      genres: genres ?? this.genres,
      credits: credits ?? this.credits,
      releases: releases ?? this.releases,
      trackCount: trackCount ?? this.trackCount,
      tracks: tracks ?? this.tracks,
      creators: creators ?? this.creators,
      links: links ?? this.links,
      synopsis: synopsis ?? this.synopsis,
      series: series ?? this.series,
      music: music ?? this.music,
      publishing: publishing ?? this.publishing,
      editionTitle: editionTitle ?? this.editionTitle,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      packaging: packaging ?? this.packaging,
      recordLabel: recordLabel ?? this.recordLabel,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      country: country ?? this.country,
      language: language ?? this.language,
    );
  }

  factory MusicCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final rawPayload = Map<String, dynamic>.from(json);
    final rawLinks = <TrailerLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e))) ??
          const <TrailerLink>[]),
    ];

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];

    final dynamic musicRaw = json['music'];
    final Map<String, dynamic>? music = musicRaw is Map
        ? Map<String, dynamic>.from(musicRaw)
        : (musicRaw != null
            ? () {
                try {
                  final dynamic res = (musicRaw as dynamic).toJson();
                  if (res is Map) return Map<String, dynamic>.from(res);
                } catch (_) {}
                return null;
              }()
            : null);
    final musicMap = music ?? json;

    final dynamic seriesRaw = json['series'];
    final CatalogSeriesDetailsDto? series = seriesRaw is CatalogSeriesDetailsDto
        ? seriesRaw
        : (seriesRaw is Map
            ? CatalogSeriesDetailsDto.fromJson(
                Map<String, dynamic>.from(seriesRaw))
            : (seriesRaw != null
                ? () {
                    try {
                      final dynamic res = (seriesRaw as dynamic).toJson();
                      if (res is Map) {
                        return CatalogSeriesDetailsDto.fromJson(
                            Map<String, dynamic>.from(res));
                      }
                    } catch (_) {}
                    return null;
                  }()
                : CatalogSeriesDetailsDto.fromJson(json)));

    final dynamic pubRaw = json['publishing'];
    final CatalogPublishingDetailsDto? publishing =
        pubRaw is CatalogPublishingDetailsDto
            ? pubRaw
            : (pubRaw is Map
                ? CatalogPublishingDetailsDto.fromJson(
                    Map<String, dynamic>.from(pubRaw))
                : (pubRaw != null
                    ? () {
                        try {
                          final dynamic res = (pubRaw as dynamic).toJson();
                          if (res is Map) {
                            return CatalogPublishingDetailsDto.fromJson(
                                Map<String, dynamic>.from(res));
                          }
                        } catch (_) {}
                        return null;
                      }()
                    : CatalogPublishingDetailsDto.fromJson(json)));

    final rawTracks = ((json['tracks'] ?? musicMap['tracks']) as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => CatalogTrackDto.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false) ??
        const <CatalogTrackDto>[];

    final resolvedArtist = (json['artist'] ??
        json['series_title'] ??
        series?.seriesTitle) as String?;

    return MusicCatalogMetadata(
      rawPayload: rawPayload,
      title: (json['title'] as String?) ?? '',
      artist: resolvedArtist,
      originalReleaseDate: json['original_release_date'] != null
          ? DateTime.tryParse(json['original_release_date'] as String)
          : null,
      recordingDate: json['recording_date'] != null
          ? DateTime.tryParse(json['recording_date'] as String)
          : null,
      studio: json['studio'] as String?,
      isLive: (json['is_live'] ?? musicMap['is_live']) as bool? ?? false,
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
      trackCount: (json['track_count'] ?? musicMap['track_count']) as int? ??
          (rawTracks.isNotEmpty ? rawTracks.length : null),
      tracks: rawTracks,
      creators: rawCreators,
      links: rawLinks,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      series: series ??
          (resolvedArtist != null
              ? CatalogSeriesDetailsDto(seriesTitle: resolvedArtist)
              : null),
      music: music,
      publishing: publishing,
      editionTitle: json['edition_title'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      packaging: (json['packaging'] ?? musicMap['packaging']) as String?,
      recordLabel: (json['record_label'] ?? json['publisher']) as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
      country: json['country'] as String?,
      language: json['language'] as String?,
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
