// ignore_for_file: use_super_parameters

class CatalogTrack {
  const CatalogTrack({
    required this.title,
    this.position,
    this.durationSeconds,
    this.artist,
    this.discNumber,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
  final String? artist;
  final int? discNumber;

  factory CatalogTrack.fromJson(Map<String, dynamic> json) {
    return CatalogTrack(
      title: json['title'] as String? ?? 'Untitled track',
      position: json['position'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      artist: json['artist'] as String?,
      discNumber: json['disc_number'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (position != null) 'position': position,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (artist != null) 'artist': artist,
      if (discNumber != null) 'disc_number': discNumber,
    };
  }
}

class CatalogVariant {
  const CatalogVariant({
    required this.id,
    required this.name,
    this.variantType,
    this.sku,
    this.barcode,
    this.isbn,
    this.region,
    this.platform,
    this.coverPriceCents,
    this.currency,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.description,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.metadata,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? variantType;
  final String? sku;
  final String? barcode;
  final String? isbn;
  final String? region;
  final String? platform;
  final int? coverPriceCents;
  final String? currency;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? description;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic>? metadata;
  final bool isPrimary;

  factory CatalogVariant.fromJson(Map<String, dynamic> json) {
    return CatalogVariant(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Variant',
      variantType: json['variant_type'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      isbn: json['isbn'] as String?,
      region: json['region'] as String?,
      platform: json['platform'] as String?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      description: json['description'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      metadata: (json['metadata_json'] as Map<String, dynamic>?)
          ?.cast<String, dynamic>(),
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (variantType != null) 'variant_type': variantType,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (isbn != null) 'isbn': isbn,
      if (region != null) 'region': region,
      if (platform != null) 'platform': platform,
      if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
      if (currency != null) 'currency': currency,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      if (description != null) 'description': description,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      if (metadata != null) 'metadata_json': metadata,
      'is_primary': isPrimary,
    };
  }
}

class CatalogEdition {
  const CatalogEdition({
    required this.id,
    required this.title,
    this.format,
    this.publisher,
    this.isbn,
    this.upc,
    this.language,
    this.region,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.metadata,
    this.variants = const <CatalogVariant>[],
  });

  final String id;
  final String title;
  final String? format;
  final String? publisher;
  final String? isbn;
  final String? upc;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic>? metadata;
  final List<CatalogVariant> variants;

  factory CatalogEdition.fromJson(Map<String, dynamic> json) {
    return CatalogEdition(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Edition',
      format: json['format'] as String?,
      publisher: json['publisher'] as String?,
      isbn: json['isbn'] as String?,
      upc: json['upc'] as String?,
      language: json['language'] as String?,
      region: json['region'] as String?,
      releaseDate: CatalogItem._parseDate(json['release_date'] as String?),
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      metadata: (json['metadata_json'] as Map<String, dynamic>?)
          ?.cast<String, dynamic>(),
      variants: (json['variants'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CatalogVariant.fromJson)
              .toList(growable: false) ??
          const <CatalogVariant>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (format != null) 'format': format,
      if (publisher != null) 'publisher': publisher,
      if (isbn != null) 'isbn': isbn,
      if (upc != null) 'upc': upc,
      if (language != null) 'language': language,
      if (region != null) 'region': region,
      if (releaseDate != null) 'release_date': releaseDate!.toUtc().toIso8601String(),
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      if (metadata != null) 'metadata_json': metadata,
      'variants': variants.map((variant) => variant.toJson()).toList(growable: false),
    };
  }
}

class MusicCatalogDetails {
  const MusicCatalogDetails({
    this.trackCount,
    this.tracks = const <CatalogTrack>[],
    this.catalogNumber,
    this.releaseStatus,
  });

  final int? trackCount;
  final List<CatalogTrack> tracks;
  final String? catalogNumber;
  final String? releaseStatus;

  bool get hasData =>
      trackCount != null ||
      tracks.isNotEmpty ||
      catalogNumber != null ||
      releaseStatus != null;
}

class CatalogSeriesDetails {
  const CatalogSeriesDetails({
    this.seriesId,
    this.seriesTitle,
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.seasonNumber,
    this.episodeNumber,
    this.tags = const <String>[],
  });

  final String? seriesId;
  final String? seriesTitle;
  final String? volumeName;
  final int? volumeNumber;
  final int? volumeStartYear;
  final int? seasonNumber;
  final int? episodeNumber;
  final List<String> tags;

  bool get hasData =>
      seriesId != null ||
      seriesTitle != null ||
      volumeName != null ||
      volumeNumber != null ||
      volumeStartYear != null ||
      seasonNumber != null ||
      episodeNumber != null ||
      tags.isNotEmpty;

  bool get hasVolume => volumeName != null || volumeNumber != null;
  bool get hasSeason => seasonNumber != null;
  bool get hasEpisode => episodeNumber != null;
}

class CatalogPublishingDetails {
  const CatalogPublishingDetails({
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
  });

  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;

  bool get hasData =>
      pageCount != null ||
      coverPriceCents != null ||
      currency != null ||
      imprint != null ||
      subtitle != null ||
      seriesGroup != null;
}

class VideoCatalogDetails {
  const VideoCatalogDetails({this.runtimeMinutes});

  final int? runtimeMinutes;

  bool get hasData => runtimeMinutes != null;
}

class GameCatalogDetails {
  const GameCatalogDetails({this.platforms = const <String>[]});

  final List<String> platforms;

  bool get hasData => platforms.isNotEmpty;
}

sealed class CatalogItem {
  const CatalogItem._({
    required this.id,
    required this.kind,
    required this.title,
    this.sortKey,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.creators,
    this.characters,
    this.storyArcs,
    this.editions = const <CatalogEdition>[],
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    this.rawPlatforms,
  });

  factory CatalogItem({
    required String id,
    required String kind,
    required String title,
    String? sortKey,
    String? itemNumber,
    String? synopsis,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    String? coverImageData,
    String? editionTitle,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    DateTime? releaseDate,
    int? releaseYear,
    String? barcode,
    String? variant,
    CatalogSeriesDetails? series,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
    CatalogPublishingDetails? publishing,
    List<Map<String, dynamic>>? creators,
    List<String>? characters,
    List<String>? storyArcs,
    List<String>? rawPlatforms,
    List<String>? genres,
    List<CatalogEdition>? editions,
    String? country,
    String? language,
    String? ageRating,
  }) {
    final normalizedKind = _normalizeKind(kind);
    final common = _CatalogItemCommon(
      id: id,
      kind: normalizedKind,
      title: title,
      sortKey: sortKey,
      itemNumber: itemNumber,
      synopsis: synopsis,
      coverImageUrl: coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl,
      coverImageData: coverImageData,
      editionTitle: editionTitle,
      physicalFormat: physicalFormat,
      physicalFormatLabel: physicalFormatLabel,
      publisher: publisher,
      releaseDate: releaseDate,
      releaseYear: releaseYear,
      barcode: barcode,
      variant: variant,
      creators: _normalizeMapList(creators),
      characters: _normalizeStringList(characters),
      storyArcs: _normalizeStringList(storyArcs),
      editions: _normalizeEditionList(editions),
      genres: _normalizeStringList(genres),
      country: country,
      language: language,
      ageRating: ageRating,
      rawPlatforms: _normalizeStringList(rawPlatforms ?? game?.platforms),
    );
    series = series == null ? null : _seriesOrNull(series);
    publishing = publishing == null ? null : _publishingOrNull(publishing);
    video = video == null ? null : _videoOrNull(video);
    music = music == null ? null : _musicOrNull(music);
    game = game == null ? null : _gameOrNull(game);

    switch (normalizedKind) {
      case 'comic':
        return ComicCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'manga':
        return MangaCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'book':
        return BookCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'movie':
        return MovieCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'tv':
        return TvCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'anime':
        return AnimeCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'music':
        return MusicCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          music: music,
        );
      case 'game':
        return GameCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      case 'boardgame':
        return BoardGameCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      default:
        return GenericCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
          music: music,
          game: game,
        );
    }
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    final series = CatalogSeriesDetails(
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number'] as int?,
      volumeStartYear: json['volume_start_year'] as int?,
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      tags: (json['tags'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
    );
    final video = VideoCatalogDetails(
      runtimeMinutes: json['runtime_minutes'] as int?,
    );
    final tracks = (json['tracks'] as List<dynamic>?)
        ?.map((track) => CatalogTrack.fromJson(track as Map<String, dynamic>))
        .toList(growable: false);
    final music = MusicCatalogDetails(
      trackCount: json['track_count'] as int?,
      tracks: tracks ?? const <CatalogTrack>[],
      catalogNumber: json['catalog_number'] as String?,
      releaseStatus: json['release_status'] as String?,
    );
    final rawPlatforms = (json['platforms'] as List<dynamic>?)
        ?.whereType<String>()
        .toList(growable: false);
    final game = GameCatalogDetails(platforms: rawPlatforms ?? const <String>[]);
    final publishing = CatalogPublishingDetails(
      pageCount: json['page_count'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      imprint: json['imprint'] as String?,
      subtitle: json['subtitle'] as String?,
      seriesGroup: json['series_group'] as String?,
    );
    final editions = (json['editions'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(CatalogEdition.fromJson)
        .toList(growable: false);
    return CatalogItem(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      sortKey: json['sort_key'] as String?,
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      coverImageData: json['cover_image_data'] as String?,
      editionTitle: json['edition_title'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      releaseDate: _parseDate(json['release_date'] as String?),
      releaseYear: json['release_year'] as int?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
        series: series.hasData ? series : null,
        video: video.hasData ? video : null,
        music: music.hasData ? music : null,
        game: game.hasData ? game : null,
        publishing: publishing.hasData ? publishing : null,
      creators: (json['creators'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .toList(growable: false),
      characters: (json['characters'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
      storyArcs: (json['story_arcs'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
      editions: editions,
        rawPlatforms: rawPlatforms,
      genres: (json['genres'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
      country: json['country'] as String?,
      language: json['language'] as String?,
      ageRating: json['age_rating'] as String?,
    );
  }

  final String id;
  final String kind;
  final String title;
  final String? sortKey;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<CatalogEdition> editions;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final List<String>? rawPlatforms;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;
  String? get displayEditionLabel =>
      physicalFormatLabel ?? variant ?? editionTitle;

  CatalogSeriesDetails? get series;
  CatalogPublishingDetails? get publishing;
  VideoCatalogDetails? get video;
  MusicCatalogDetails? get music;
  GameCatalogDetails? get game;

  Map<String, dynamic> toSyncPayload() {
    final series = this.series;
    final publishing = this.publishing;
    final video = this.video;
    final music = this.music;
    final game = this.game;
    final tracks = music?.tracks;
    final platforms = game?.platforms ?? rawPlatforms;
    return {
      'snapshot_version': 1,
      'kind': kind,
      'title': title,
      'sort_key': sortKey,
      'item_number': itemNumber,
      'synopsis': synopsis,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': thumbnailImageUrl,
      if (coverImageData != null) 'cover_image_data': coverImageData,
      'edition_title': editionTitle,
      'physical_format': physicalFormat,
      'physical_format_label': physicalFormatLabel,
      'publisher': publisher,
      'release_date': releaseDate?.toUtc().toIso8601String(),
      'release_year': releaseYear,
      'barcode': barcode,
      'variant': variant,
      'series_id': series?.seriesId,
      'series_title': series?.seriesTitle,
      'volume_name': series?.volumeName,
      'volume_number': series?.volumeNumber,
      'volume_start_year': series?.volumeStartYear,
      'season_number': series?.seasonNumber,
      'episode_number': series?.episodeNumber,
      'tags': series?.tags,
      'runtime_minutes': video?.runtimeMinutes,
      'track_count': music?.trackCount,
      'tracks': tracks?.map((track) => track.toJson()).toList(growable: false),
      'catalog_number': music?.catalogNumber,
      'editions': editions.map((edition) => edition.toJson()).toList(growable: false),
      'platforms': platforms,
      'release_status': music?.releaseStatus,
      'page_count': publishing?.pageCount,
      'cover_price_cents': publishing?.coverPriceCents,
      'currency': publishing?.currency,
      'imprint': publishing?.imprint,
      'subtitle': publishing?.subtitle,
      'series_group': publishing?.seriesGroup,
    };
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

abstract base class _TypedCatalogItem extends CatalogItem {
  _TypedCatalogItem._({
    required _CatalogItemCommon common,
    this.seriesDetails,
    this.publishingDetails,
    this.videoDetails,
    this.musicDetails,
    this.gameDetails,
  }) : super._(
          id: common.id,
          kind: common.kind,
          title: common.title,
          sortKey: common.sortKey,
          itemNumber: common.itemNumber,
          synopsis: common.synopsis,
          coverImageUrl: common.coverImageUrl,
          thumbnailImageUrl: common.thumbnailImageUrl,
          coverImageData: common.coverImageData,
          editionTitle: common.editionTitle,
          physicalFormat: common.physicalFormat,
          physicalFormatLabel: common.physicalFormatLabel,
          publisher: common.publisher,
          releaseDate: common.releaseDate,
          releaseYear: common.releaseYear,
          barcode: common.barcode,
          variant: common.variant,
          creators: common.creators,
          characters: common.characters,
          storyArcs: common.storyArcs,
          editions: common.editions ?? const <CatalogEdition>[],
          genres: common.genres,
          country: common.country,
          language: common.language,
          ageRating: common.ageRating,
          rawPlatforms: common.rawPlatforms,
        );

  final CatalogSeriesDetails? seriesDetails;
  final CatalogPublishingDetails? publishingDetails;
  final VideoCatalogDetails? videoDetails;
  final MusicCatalogDetails? musicDetails;
  final GameCatalogDetails? gameDetails;

  @override
  CatalogSeriesDetails? get series => seriesDetails;

  @override
  CatalogPublishingDetails? get publishing => publishingDetails;

  @override
  VideoCatalogDetails? get video => videoDetails;

  @override
  MusicCatalogDetails? get music => musicDetails;

  @override
  GameCatalogDetails? get game => gameDetails;
}

final class ComicCatalogItem extends _TypedCatalogItem {
  ComicCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MangaCatalogItem extends _TypedCatalogItem {
  MangaCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class BookCatalogItem extends _TypedCatalogItem {
  BookCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MovieCatalogItem extends _TypedCatalogItem {
  MovieCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class TvCatalogItem extends _TypedCatalogItem {
  TvCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class AnimeCatalogItem extends _TypedCatalogItem {
  AnimeCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class MusicCatalogItem extends _TypedCatalogItem {
  MusicCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    MusicCatalogDetails? music,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          musicDetails: music,
        );
}

final class GameCatalogItem extends _TypedCatalogItem {
  GameCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class BoardGameCatalogItem extends _TypedCatalogItem {
  BoardGameCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class GenericCatalogItem extends _TypedCatalogItem {
  GenericCatalogItem._({
    required _CatalogItemCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
          musicDetails: music,
          gameDetails: game,
        );
}

class _CatalogItemCommon {
  const _CatalogItemCommon({
    required this.id,
    required this.kind,
    required this.title,
    this.sortKey,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.creators,
    this.characters,
    this.storyArcs,
    this.editions,
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    this.rawPlatforms,
  });

  final String id;
  final String kind;
  final String title;
  final String? sortKey;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<CatalogEdition>? editions;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final List<String>? rawPlatforms;
}

CatalogSeriesDetails? _seriesOrNull(CatalogSeriesDetails details) {
  return details.hasData ? details : null;
}

CatalogPublishingDetails? _publishingOrNull(CatalogPublishingDetails details) {
  return details.hasData ? details : null;
}

VideoCatalogDetails? _videoOrNull(VideoCatalogDetails details) {
  return details.hasData ? details : null;
}

MusicCatalogDetails? _musicOrNull(MusicCatalogDetails details) {
  return details.hasData ? details : null;
}

GameCatalogDetails? _gameOrNull(GameCatalogDetails details) {
  return details.hasData ? details : null;
}

String _normalizeKind(String kind) {
  return kind.trim().toLowerCase();
}

List<String>? _normalizeStringList(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<CatalogEdition>? _normalizeEditionList(List<CatalogEdition>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<Map<String, dynamic>>? _normalizeMapList(List<Map<String, dynamic>>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}
