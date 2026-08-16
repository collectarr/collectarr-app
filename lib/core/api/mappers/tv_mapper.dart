import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';

TvEpisode tvEpisodeFromDto(dynamic dto) => const TvEpisode();

TvSeason tvSeasonFromDto(dynamic dto) => const TvSeason();

dynamic tryGet(dynamic Function() fn) {
  try {
    return fn();
  } catch (_) {
    return null;
  }
}

TvReleaseMedia tvReleaseMediaFromDto(dynamic dto) {
  if (dto == null) return const TvReleaseMedia();
  Map<String, dynamic>? jsonMap;
  if (dto is Map) {
    jsonMap = Map<String, dynamic>.from(dto);
  } else {
    try {
      jsonMap = (dto as dynamic).toJson() as Map<String, dynamic>?;
    } catch (_) {}
  }
  final episodesRaw = jsonMap != null
      ? jsonMap['episodes']
      : tryGet(() => (dto as dynamic).episodes);
  final episodes = <TvEpisode>[];
  if (episodesRaw is Iterable) {
    for (final e in episodesRaw) {
      if (e is Map<String, dynamic>) episodes.add(TvEpisode.fromJson(e));
    }
  }
  final discNo = jsonMap != null
      ? jsonMap['disc_number'] as int?
      : tryGet(() => (dto as dynamic).discNumber) as int?;
  return TvReleaseMedia(
    id: jsonMap != null
        ? (jsonMap['id'] as String? ?? '')
        : ((tryGet(() => (dto as dynamic).id) ?? '') as String),
    discNumber: discNo,
    episodes: episodes,
  );
}

TvReleaseEpisodeMap tvReleaseEpisodeMapFromDto(dynamic dto) {
  if (dto == null) return const TvReleaseEpisodeMap();
  Map<String, dynamic>? jsonMap;
  if (dto is Map) {
    jsonMap = Map<String, dynamic>.from(dto);
  } else {
    try {
      jsonMap = (dto as dynamic).toJson() as Map<String, dynamic>?;
    } catch (_) {}
  }
  return TvReleaseEpisodeMap(
    id: jsonMap != null
        ? (jsonMap['id'] as String? ?? '')
        : ((tryGet(() => (dto as dynamic).id) ?? '') as String),
    releaseId: jsonMap != null
        ? jsonMap['release_id'] as String?
        : tryGet(() => (dto as dynamic).releaseId) as String?,
    mediaId: jsonMap != null
        ? jsonMap['media_id'] as String?
        : tryGet(() => (dto as dynamic).mediaId) as String?,
    episodeId: jsonMap != null
        ? jsonMap['episode_id'] as String?
        : tryGet(() => (dto as dynamic).episodeId) as String?,
    discNumber: jsonMap != null
        ? jsonMap['disc_number'] as int?
        : tryGet(() => (dto as dynamic).discNumber) as int?,
    sequenceNumber: jsonMap != null
        ? jsonMap['sequence_number'] as int?
        : tryGet(() => (dto as dynamic).sequenceNumber) as int?,
  );
}

TvRelease tvReleaseFromDto(dynamic dto) {
  if (dto == null) return const TvRelease(id: '', seriesId: '');
  Map<String, dynamic>? jsonMap;
  if (dto is Map) {
    jsonMap = Map<String, dynamic>.from(dto);
  } else {
    try {
      jsonMap = (dto as dynamic).toJson() as Map<String, dynamic>?;
    } catch (_) {}
  }
  final mediaRaw =
      jsonMap != null ? jsonMap['media'] : tryGet(() => (dto as dynamic).media);
  final mediaList = <TvReleaseMedia>[];
  if (mediaRaw is Iterable) {
    for (final m in mediaRaw) {
      mediaList.add(tvReleaseMediaFromDto(m));
    }
  }
  return TvRelease(
    id: jsonMap != null
        ? (jsonMap['id'] as String? ?? '')
        : ((tryGet(() => (dto as dynamic).id) ?? '') as String),
    seriesId: jsonMap != null
        ? (jsonMap['series_id'] as String? ?? '')
        : ((tryGet(() => (dto as dynamic).seriesId) ?? '') as String),
    title: jsonMap != null
        ? jsonMap['title'] as String?
        : tryGet(() => (dto as dynamic).title) as String?,
    media: mediaList,
  );
}

TvSeries tvSeriesFromDto(dynamic dto) {
  if (dto == null) return const TvSeries();
  Map<String, dynamic>? jsonMap;
  if (dto is Map) {
    jsonMap = Map<String, dynamic>.from(dto);
  } else {
    try {
      jsonMap = (dto as dynamic).toJson() as Map<String, dynamic>?;
    } catch (_) {}
  }

  dynamic releasesRaw = jsonMap != null
      ? (jsonMap['releases'] ?? jsonMap['editions'] ?? jsonMap['episodes'])
      : null;
  if (releasesRaw == null && dto != null) {
    try {
      releasesRaw = (dto as dynamic).releases;
    } catch (_) {
      try {
        releasesRaw = (dto as dynamic).editions;
      } catch (_) {
        try {
          releasesRaw = (dto as dynamic).episodes;
        } catch (_) {}
      }
    }
  }
  final String id = jsonMap != null
      ? (jsonMap['id'] as String? ?? '')
      : ((dto as dynamic).id as String? ?? '');
  final String title = jsonMap != null
      ? (jsonMap['title'] as String? ?? '')
      : ((dto as dynamic).title as String? ?? '');

  final releases = <TvRelease>[];
  if (releasesRaw is Iterable) {
    for (final r in releasesRaw) {
      if (r == null) continue;
      final rId = r is Map
          ? (r['id'] as String? ?? '')
          : ((r as dynamic).id as String? ?? '');
      final rTitle =
          r is Map ? r['title'] as String? : (r as dynamic).title as String?;
      final rPub = r is Map
          ? r['publisher'] as String?
          : (r as dynamic).publisher as String?;
      final rDist = r is Map
          ? r['distributor'] as String?
          : (r as dynamic).distributor as String?;
      final rBar = r is Map
          ? r['barcode'] as String?
          : (r as dynamic).barcode as String?;
      final rFmt = r is Map
          ? r['format_label'] as String?
          : (r as dynamic).formatLabel as String?;

      final mediaRaw = r is Map ? r['media'] : (r as dynamic).media;
      final mediaList = <TvReleaseMedia>[];
      if (mediaRaw is Iterable) {
        for (final m in mediaRaw) {
          if (m == null) continue;
          mediaList.add(TvReleaseMedia(
            id: m is Map
                ? (m['id'] as String? ?? '')
                : ((m as dynamic).id as String? ?? ''),
            releaseId: m is Map
                ? (m['release_id'] as String? ?? '')
                : ((m as dynamic).releaseId as String? ?? ''),
            discNumber: m is Map
                ? m['disc_number'] as int?
                : (m as dynamic).discNumber as int?,
            title: m is Map
                ? m['title'] as String?
                : (m as dynamic).title as String?,
            formatLabel: m is Map
                ? m['format_label'] as String?
                : (m as dynamic).formatLabel as String?,
          ));
        }
      }

      dynamic mapsRaw;
      try {
        mapsRaw = r is Map
            ? (r['episode_mappings'] ?? r['episode_maps'])
            : (r as dynamic).episodeMappings;
      } catch (_) {}

      final mapList = <TvReleaseEpisodeMap>[];
      if (mapsRaw is Iterable) {
        for (final e in mapsRaw) {
          if (e == null) continue;
          mapList.add(TvReleaseEpisodeMap(
            id: e is Map
                ? (e['id'] as String? ?? '')
                : ((e as dynamic).id as String? ?? ''),
            releaseId: e is Map
                ? e['release_id'] as String?
                : (e as dynamic).releaseId as String?,
            mediaId: e is Map
                ? e['media_id'] as String?
                : (e as dynamic).mediaId as String?,
            episodeId: e is Map
                ? e['episode_id'] as String?
                : (e as dynamic).episodeId as String?,
            discNumber: e is Map
                ? e['disc_number'] as int?
                : (e as dynamic).discNumber as int?,
            sequenceNumber: e is Map
                ? e['sequence_number'] as int?
                : (e as dynamic).sequenceNumber as int?,
          ));
        }
      }

      releases.add(TvRelease(
        id: rId,
        seriesId: id,
        title: rTitle,
        publisher: rPub,
        distributor: rDist,
        barcode: rBar,
        formatLabel: rFmt,
        media: mediaList,
        episodeMappings: mapList,
      ));
    }
  }

  return TvSeries(
    id: id,
    title: title,
    releases: releases,
  );
}
