import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

final class MusicWork {
  const MusicWork({
    required this.id,
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.searchAliases = const <String>[],
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.publisher,
    this.coverDate,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.crossover,
    this.series,
    this.publishing,
    this.music,
    this.trailerUrls = const <TrailerLink>[],
    this.creators,
    this.characters = const <String>[],
    this.storyArcs = const <String>[],
    this.editions = const <CatalogEdition>[],
    this.genres = const <String>[],
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
  });

  final String id;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final List<String> searchAliases;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? coverDate;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final String? crossover;
  final CatalogSeriesDetails? series;
  final CatalogPublishingDetails? publishing;
  final MusicCatalogDetails? music;
  final List<TrailerLink> trailerUrls;
  final List<Map<String, dynamic>>? creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<CatalogEdition> editions;
  final List<String> genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  String? get displayEditionLabel =>
      variant ?? music?.catalogNumber ?? music?.releaseStatus;

  bool get hasMissingCoreMetadata =>
      publisher == null &&
      releaseDate == null &&
      releaseYear == null &&
      displayCoverUrl == null &&
      displayEditionLabel == null;

  factory MusicWork.fromMetadataItem(LibraryMetadataItem item) {
    return MusicWork(
      id: item.id,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      searchAliases:
          List<String>.unmodifiable(item.searchAliases ?? const <String>[]),
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
      publisher: item.publisher,
      coverDate: item.coverDate,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      barcode: item.barcode,
      variant: item.variant,
      crossover: item.crossover,
      series: item.series,
      publishing: item.publishing,
      music: item.music,
      trailerUrls: List<TrailerLink>.unmodifiable(item.trailerUrls),
      creators: item.creators == null
          ? null
          : List<Map<String, dynamic>>.unmodifiable(
              item.creators!
                  .map((entry) => Map<String, dynamic>.unmodifiable(entry)),
            ),
      characters:
          List<String>.unmodifiable(item.characters ?? const <String>[]),
      storyArcs: List<String>.unmodifiable(item.storyArcs ?? const <String>[]),
      editions: List<CatalogEdition>.unmodifiable(item.editions),
      genres: List<String>.unmodifiable(item.genres ?? const <String>[]),
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
      audienceRating: item.audienceRating,
    );
  }
}

final class MusicTrack {
  const MusicTrack({
    required this.title,
    this.position,
    this.durationSeconds,
    this.offsetMilliseconds,
    this.bitrateKbps,
    this.fileSizeBytes,
    this.trackHash,
    this.artist,
    this.discNumber,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
  final int? offsetMilliseconds;
  final int? bitrateKbps;
  final int? fileSizeBytes;
  final String? trackHash;
  final String? artist;
  final int? discNumber;

  factory MusicTrack.fromDto(MusicTrackDto dto) {
    return MusicTrack(
      title: dto.title,
      position: _parseInt(dto.position),
      durationSeconds:
          dto.durationMs == null ? null : (dto.durationMs! ~/ 1000),
      offsetMilliseconds: _parseInt(dto.raw['offset_ms']?.toString() ?? ''),
      bitrateKbps: _parseInt(dto.raw['bitrate_kbps']?.toString() ?? ''),
      fileSizeBytes: _parseInt(dto.raw['file_size_bytes']?.toString() ?? ''),
      trackHash: _stringOrNull(dto.raw['track_hash']),
    );
  }

  CatalogTrack toCatalogTrack({required int discNumber}) {
    return CatalogTrack(
      title: title,
      position: position,
      durationSeconds: durationSeconds,
      offsetMilliseconds: offsetMilliseconds,
      bitrateKbps: bitrateKbps,
      fileSizeBytes: fileSizeBytes,
      trackHash: trackHash,
      artist: artist,
      discNumber: discNumber,
    );
  }
}

final class MusicMedia {
  const MusicMedia({
    required this.id,
    required this.title,
    required this.mediaNumber,
    this.mediaCondition,
    this.mediaType,
    this.packaging,
    this.rpm,
    this.soundType,
    this.spars,
    this.trackCount,
    this.expectedTrackCount,
    this.ownedTrackCount,
    this.missingTrackCount,
    this.missingTrackPositions = const <String>[],
    this.toc,
    this.cddbId,
    this.leadoutOffset,
    this.bpDiscId,
    this.vinylColor,
    this.vinylWeight,
    this.tracks = const <MusicTrack>[],
  });

  final String id;
  final String title;
  final int mediaNumber;
  final String? mediaCondition;
  final String? mediaType;
  final String? packaging;
  final int? rpm;
  final String? soundType;
  final String? spars;
  final int? trackCount;
  final int? expectedTrackCount;
  final int? ownedTrackCount;
  final int? missingTrackCount;
  final List<String> missingTrackPositions;
  final String? toc;
  final String? cddbId;
  final int? leadoutOffset;
  final String? bpDiscId;
  final String? vinylColor;
  final String? vinylWeight;
  final List<MusicTrack> tracks;

  factory MusicMedia.fromDto(MusicMediaDto dto) {
    return MusicMedia(
      id: dto.id,
      title: dto.title,
      mediaNumber: dto.mediaNumber,
      mediaCondition: dto.mediaCondition,
      mediaType: dto.mediaType,
      packaging: dto.packaging,
      rpm: dto.rpm,
      soundType: dto.soundType,
      spars: dto.spars,
      trackCount: dto.trackCount,
      expectedTrackCount: _parseInt(
        dto.raw['expected_track_count']?.toString() ?? '',
      ),
      ownedTrackCount: _parseInt(
        dto.raw['owned_track_count']?.toString() ?? '',
      ),
      missingTrackCount: _parseInt(
        dto.raw['missing_track_count']?.toString() ?? '',
      ),
      missingTrackPositions: _stringList(dto.raw['missing_track_positions']),
      toc: _stringOrNull(dto.raw['toc']),
      cddbId: _stringOrNull(dto.raw['cddb_id']),
      leadoutOffset: _parseInt(dto.raw['leadout_offset']?.toString() ?? ''),
      bpDiscId: _stringOrNull(dto.raw['bp_disc_id']),
      vinylColor: dto.vinylColor,
      vinylWeight: dto.vinylWeight,
      tracks: [
        for (final track in dto.tracks) MusicTrack.fromDto(track),
      ],
    );
  }

  CatalogDisc toCatalogDisc() {
    return CatalogDisc(
      discNumber: mediaNumber,
      discName: title,
      discFormat: mediaType,
      trackCount: trackCount,
      expectedTrackCount: expectedTrackCount,
      ownedTrackCount: ownedTrackCount,
      missingTrackCount: missingTrackCount,
      missingTrackPositions: missingTrackPositions,
      toc: toc,
      cddbId: cddbId,
      leadoutOffset: leadoutOffset,
      bpDiscId: bpDiscId,
      packaging: packaging,
      mediaCondition: mediaCondition,
      soundType: soundType,
      rpm: rpm,
      vinylColor: vinylColor,
      vinylWeight: vinylWeight,
      tracks: [
        for (final track in tracks)
          track.toCatalogTrack(discNumber: mediaNumber)
      ],
    );
  }

  List<CatalogTrack> toCatalogTracks() {
    return [
      for (final track in tracks) track.toCatalogTrack(discNumber: mediaNumber),
    ];
  }
}

final class MusicRelease {
  const MusicRelease({
    required this.id,
    required this.title,
    this.artist,
    this.subtitle,
    this.publisher,
    this.catalogNumber,
    this.upc,
    this.recordingDate,
    this.originalReleaseDate,
    this.releaseDate,
    this.releaseStatus,
    this.releaseType,
    this.sortTitle,
    this.studio,
    this.trackCount,
    this.barcode,
    this.coverImageUrl,
    this.language,
    this.countryCode,
    this.extras,
    this.mediaCondition,
    this.instrument,
    this.composition,
    this.rpm,
    this.spars,
    this.soundType,
    this.vinylColor,
    this.vinylWeight,
    this.expectedMediaCount,
    this.ownedMediaCount,
    this.missingMediaCount,
    this.missingDiscNumbers = const <int>[],
    this.localCoverImagePath,
    this.localBackImagePath,
    this.localThumbnailImagePath,
    this.genres = const <String>[],
    this.creators = const <Map<String, dynamic>>[],
    this.identifiers = const <dynamic>[],
    this.media = const <MusicMedia>[],
  });

  final String id;
  final String title;
  final String? artist;
  final String? subtitle;
  final String? publisher;
  final String? catalogNumber;
  final String? upc;
  final DateTime? recordingDate;
  final DateTime? originalReleaseDate;
  final DateTime? releaseDate;
  final String? releaseStatus;
  final String? releaseType;
  final String? sortTitle;
  final String? studio;
  final int? trackCount;
  final String? barcode;
  final String? coverImageUrl;
  final String? language;
  final String? countryCode;
  final String? extras;
  final String? mediaCondition;
  final String? instrument;
  final String? composition;
  final String? rpm;
  final String? spars;
  final String? soundType;
  final String? vinylColor;
  final String? vinylWeight;
  final int? expectedMediaCount;
  final int? ownedMediaCount;
  final int? missingMediaCount;
  final List<int> missingDiscNumbers;
  final String? localCoverImagePath;
  final String? localBackImagePath;
  final String? localThumbnailImagePath;
  final List<String> genres;
  final List<Map<String, dynamic>> creators;
  final List<dynamic> identifiers;
  final List<MusicMedia> media;

  List<CatalogDisc> get discs =>
      [for (final media in this.media) media.toCatalogDisc()];

  List<CatalogTrack> get tracks =>
      [for (final media in this.media) ...media.toCatalogTracks()];

  int get discCount => media.isEmpty ? 0 : media.length;

  String? get length {
    var totalSeconds = 0;
    for (final track in tracks) {
      final duration = track.durationSeconds;
      if (duration != null && duration > 0) {
        totalSeconds += duration;
      }
    }
    if (totalSeconds <= 0) {
      return null;
    }
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isLive => extras?.toLowerCase().contains('live') ?? false;

  factory MusicRelease.fromDto(MusicReleaseDto dto) {
    final contributors = [
      for (final entry in dto.contributions)
        if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
    ];
    return MusicRelease(
      id: dto.id,
      title: dto.title,
      artist: _artistFromContributions(contributors),
      subtitle: dto.subtitle,
      publisher: dto.publisher,
      catalogNumber:
          dto.raw['catalog_number']?.toString().trim().isNotEmpty == true
              ? dto.raw['catalog_number'].toString().trim()
              : dto.extras,
      upc: _stringOrNull(dto.raw['upc']) ?? _stringOrNull(dto.raw['barcode']),
      recordingDate: dto.recordingDate,
      originalReleaseDate: dto.releaseDate,
      releaseDate: dto.releaseDate,
      releaseStatus: dto.releaseStatus,
      releaseType: dto.releaseType,
      sortTitle: dto.sortTitle,
      studio: dto.studio,
      trackCount: dto.trackCount,
      barcode: dto.barcode,
      coverImageUrl: dto.coverImageUrl,
      language: dto.language,
      countryCode: dto.countryCode,
      extras: dto.extras,
      mediaCondition: _stringOrNull(
          dto.media.isEmpty ? null : dto.media.first.mediaCondition),
      instrument: null,
      composition: null,
      rpm: _stringOrNull(
          dto.media.isEmpty ? null : dto.media.first.rpm?.toString()),
      spars: _stringOrNull(dto.media.isEmpty ? null : dto.media.first.spars),
      soundType:
          _stringOrNull(dto.media.isEmpty ? null : dto.media.first.soundType),
      vinylColor:
          _stringOrNull(dto.media.isEmpty ? null : dto.media.first.vinylColor),
      vinylWeight:
          _stringOrNull(dto.media.isEmpty ? null : dto.media.first.vinylWeight),
      expectedMediaCount: _parseInt(
        dto.raw['expected_media_count']?.toString() ?? '',
      ),
      ownedMediaCount:
          _parseInt(dto.raw['owned_media_count']?.toString() ?? ''),
      missingMediaCount: _parseInt(
        dto.raw['missing_media_count']?.toString() ?? '',
      ),
      missingDiscNumbers: _intList(dto.raw['missing_disc_numbers']),
      localCoverImagePath: _stringOrNull(dto.raw['local_cover_image_path']),
      localBackImagePath: _stringOrNull(dto.raw['local_back_image_path']),
      localThumbnailImagePath:
          _stringOrNull(dto.raw['local_thumbnail_image_path']),
      genres: _stringList(dto.raw['genres']),
      creators: contributors,
      identifiers: List<dynamic>.unmodifiable(dto.identifiers),
      media: [for (final media in dto.media) MusicMedia.fromDto(media)],
    );
  }
}

String? _artistFromContributions(List<Map<String, dynamic>> contributions) {
  for (final contribution in contributions) {
    final role = contribution['role']?.toString().toLowerCase() ?? '';
    if (!role.contains('artist') &&
        !role.contains('performer') &&
        !role.contains('band') &&
        !role.contains('ensemble')) {
      continue;
    }
    final name = contribution['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
  }
  for (final contribution in contributions) {
    final name = contribution['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
  }
  return null;
}

int? _parseInt(String value) => int.tryParse(value.trim());

String? _stringOrNull(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return [
    for (final entry in value)
      if (entry != null && entry.toString().trim().isNotEmpty)
        entry.toString().trim(),
  ];
}

List<int> _intList(Object? value) {
  if (value is! List) {
    return const <int>[];
  }
  return [
    for (final entry in value)
      if (entry != null && int.tryParse(entry.toString().trim()) != null)
        int.parse(entry.toString().trim()),
  ];
}
