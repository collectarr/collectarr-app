// ignore_for_file: use_super_parameters

class TrailerLink {
  const TrailerLink({
    required this.url,
    this.title,
    this.description,
    this.source,
    this.isAutomatic = true,
    this.kind = 'trailer',
  });

  final String url;
  final String? title;
  final String? description;
  final String? source;
  final bool isAutomatic;
  final String kind;

  bool get isExternalLink => kind == 'external' || kind == 'link';
  bool get isTrailerLink => !isExternalLink;

  factory TrailerLink.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? json['type'])?.toString().toLowerCase();
    final source = json['source'] as String?;
    final inferredKind = rawKind ??
        ((source?.toLowerCase().contains('external') ?? false)
            ? 'external'
            : 'trailer');
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    return TrailerLink(
      url: json['url'] as String,
      title: title ?? description,
      description: description ?? title,
      source: source,
      isAutomatic: json['is_automatic'] as bool? ?? true,
      kind: inferredKind,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (source != null) 'source': source,
      'is_automatic': isAutomatic,
      'kind': kind,
    };
  }
}

class CatalogDisc {
  const CatalogDisc({
    required this.discNumber,
    this.discName,
    this.discFormat,
    this.storageDevice,
    this.slot,
    this.matrixSideA,
    this.matrixSideB,
  });

  final int discNumber;
  final String? discName;
  final String? discFormat;
  final String? storageDevice;
  final String? slot;
  final String? matrixSideA;
  final String? matrixSideB;

  factory CatalogDisc.fromJson(Map<String, dynamic> json) {
    return CatalogDisc(
      discNumber: json['disc_number'] as int? ?? 1,
      discName: json['disc_name'] as String?,
      discFormat: json['disc_format'] as String?,
      storageDevice: json['storage_device'] as String?,
      slot: json['slot'] as String?,
      matrixSideA: json['matrix_side_a'] as String?,
      matrixSideB: json['matrix_side_b'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disc_number': discNumber,
      if (discName != null) 'disc_name': discName,
      if (discFormat != null) 'disc_format': discFormat,
      if (storageDevice != null) 'storage_device': storageDevice,
      if (slot != null) 'slot': slot,
      if (matrixSideA != null) 'matrix_side_a': matrixSideA,
      if (matrixSideB != null) 'matrix_side_b': matrixSideB,
    };
  }
}

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
      metadata: const <String, dynamic>{},
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
    this.distributor,
    this.isbn,
    this.upc,
    this.language,
    this.region,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.metadata,
    this.variants = const <CatalogVariant>[],
    this.discs = const <CatalogDisc>[],
  });

  final String id;
  final String title;
  final String? format;
  final String? publisher;
  final String? distributor;
  final String? isbn;
  final String? upc;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final Map<String, dynamic>? metadata;
  final List<CatalogVariant> variants;
  final List<CatalogDisc> discs;

  factory CatalogEdition.fromJson(Map<String, dynamic> json) {
    return CatalogEdition(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Edition',
      format: json['format'] as String?,
      publisher: json['publisher'] as String?,
      distributor: json['distributor'] as String?,
      isbn: json['isbn'] as String?,
      upc: json['upc'] as String?,
      language: json['language'] as String?,
      region: json['region'] as String?,
      releaseDate: CatalogItem._parseDate(json['release_date'] as String?),
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      metadata: const <String, dynamic>{},
      variants: (json['variants'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CatalogVariant.fromJson)
              .toList(growable: false) ??
          const <CatalogVariant>[],
      discs: (json['discs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CatalogDisc.fromJson)
              .toList(growable: false) ??
          const <CatalogDisc>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (format != null) 'format': format,
      if (publisher != null) 'publisher': publisher,
      if (distributor != null) 'distributor': distributor,
      if (isbn != null) 'isbn': isbn,
      if (upc != null) 'upc': upc,
      if (language != null) 'language': language,
      if (region != null) 'region': region,
      if (releaseDate != null)
        'release_date': releaseDate!.toUtc().toIso8601String(),
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (physicalFormatLabel != null)
        'physical_format_label': physicalFormatLabel,
      'variants':
          variants.map((variant) => variant.toJson()).toList(growable: false),
      if (discs.isNotEmpty)
        'discs': discs.map((disc) => disc.toJson()).toList(growable: false),
    };
  }
}

class MusicCatalogDetails {
  const MusicCatalogDetails({
    this.trackCount,
    this.tracks = const <CatalogTrack>[],
    this.discs = const <CatalogDisc>[],
    this.catalogNumber,
    this.releaseStatus,
    this.originalReleaseDate,
    this.recordingDate,
    this.studio,
    this.rpm,
    this.spars,
    this.soundType,
    this.vinylColor,
    this.vinylWeight,
    this.mediaCondition,
    this.instrument,
    this.isLive,
    this.composition,
  });

  final int? trackCount;
  final List<CatalogTrack> tracks;
  final List<CatalogDisc> discs;
  final String? catalogNumber;
  final String? releaseStatus;
  final DateTime? originalReleaseDate;
  final DateTime? recordingDate;
  final String? studio;
  final String? rpm;
  final String? spars;
  final String? soundType;
  final String? vinylColor;
  final String? vinylWeight;
  final String? mediaCondition;
  final String? instrument;
  final bool? isLive;
  final String? composition;

  bool get hasData =>
      trackCount != null ||
      tracks.isNotEmpty ||
      discs.isNotEmpty ||
      catalogNumber != null ||
      releaseStatus != null ||
      originalReleaseDate != null ||
      recordingDate != null ||
      studio != null ||
      rpm != null ||
      spars != null ||
      soundType != null ||
      vinylColor != null ||
      vinylWeight != null ||
      mediaCondition != null ||
      instrument != null ||
      isLive != null ||
      composition != null;
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
  final double? volumeNumber;
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
    this.publicationPlace,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublicationDate,
    this.originalPublicationPlace,
    this.originalPublisher,
    this.paperType,
    this.printedBy,
    this.subjects = const <String>[],
    this.dustJacketCondition,
    this.dustJacket,
    this.audiobookAbridged,
    this.firstEdition,
  });

  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final String? publicationPlace;
  final String? originalCountry;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final String? originalPublicationPlace;
  final String? originalPublisher;
  final String? paperType;
  final String? printedBy;
  final List<String> subjects;
  final String? dustJacketCondition;
  final bool? dustJacket;
  final bool? audiobookAbridged;
  final bool? firstEdition;

  bool get hasData =>
      pageCount != null ||
      coverPriceCents != null ||
      currency != null ||
      imprint != null ||
      subtitle != null ||
      seriesGroup != null ||
      publicationPlace != null ||
      originalCountry != null ||
      originalLanguage != null ||
      originalPublicationDate != null ||
      originalPublicationPlace != null ||
      originalPublisher != null ||
      paperType != null ||
      printedBy != null ||
      subjects.isNotEmpty ||
      dustJacketCondition != null ||
      dustJacket != null ||
      audiobookAbridged != null ||
      firstEdition != null;
}

class VideoCatalogDetails {
  const VideoCatalogDetails({
    this.runtimeMinutes,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.ageRating,
    this.audienceRating,
  });

  final int? runtimeMinutes;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? ageRating;
  final String? audienceRating;

  bool get hasData =>
      runtimeMinutes != null ||
      color != null ||
      nrDiscs != null ||
      screenRatio != null ||
      audioTracks != null ||
      subtitles != null ||
      layers != null ||
      ageRating != null ||
      audienceRating != null;
}

class GameCatalogDetails {
  const GameCatalogDetails({
    this.platforms = const <String>[],
    this.toySubtype,
    this.toyType,
  });

  final List<String> platforms;
  final String? toySubtype;
  final String? toyType;

  bool get hasData =>
      platforms.isNotEmpty || toySubtype != null || toyType != null;
}

enum CatalogMediaKind {
  comic('comic'),
  manga('manga'),
  anime('anime'),
  book('book'),
  game('game'),
  boardgame('boardgame'),
  movie('movie'),
  tv('tv'),
  music('music'),
  unknown('unknown');

  const CatalogMediaKind(this.apiValue);

  final String apiValue;
}

extension CatalogMediaKindLibrarySemantics on CatalogMediaKind {
  CatalogMediaKind get libraryKind => this;

  bool get isVideoLibraryKind {
    return switch (this) {
      CatalogMediaKind.movie ||
      CatalogMediaKind.tv ||
      CatalogMediaKind.anime =>
        true,
      _ => false,
    };
  }
}

CatalogMediaKind catalogMediaKindFromValue(Object? value) {
  if (value is CatalogMediaKind) {
    return value;
  }
  if (value is String?) {
    return catalogMediaKindFromApiValue(value);
  }
  return CatalogMediaKind.unknown;
}

CatalogMediaKind catalogMediaKindFromApiValue(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null) return CatalogMediaKind.unknown;

  for (final kind in CatalogMediaKind.values) {
    if (kind.apiValue == normalized) {
      return kind;
    }
  }
  return CatalogMediaKind.unknown;
}

sealed class CatalogItem {
  const CatalogItem._({
    required this.id,
    required this.mediaKind,
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.titleExtension,
    this.searchAliases,
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
    this.coverDate,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.crossover,
    this.plotSummary,
    this.plotDescription,
    this.creators,
    this.characters,
    this.characterDetails,
    this.storyArcs,
    this.editions = const <CatalogEdition>[],
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.rawPlatforms,
    this.trailerUrls = const <TrailerLink>[],
  });

  factory CatalogItem({
    required String id,
    String? kind,
    CatalogMediaKind? mediaKind,
    required String title,
    String? displayTitle,
    String? localizedTitle,
    String? originalTitle,
    String? titleExtension,
    List<String>? searchAliases,
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
    DateTime? coverDate,
    DateTime? releaseDate,
    int? releaseYear,
    String? barcode,
    String? variant,
    String? crossover,
    String? plotSummary,
    String? plotDescription,
    CatalogSeriesDetails? series,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
    CatalogPublishingDetails? publishing,
    List<Map<String, dynamic>>? creators,
    List<String>? characters,
    List<Map<String, dynamic>>? characterDetails,
    List<String>? storyArcs,
    List<String>? rawPlatforms,
    List<TrailerLink>? trailerUrls,
    List<String>? genres,
    List<CatalogEdition>? editions,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
  }) {
    final resolvedMediaKind = mediaKind ?? catalogMediaKindFromApiValue(kind);
    final common = _CatalogItemCommon(
      id: id,
      mediaKind: resolvedMediaKind,
      title: title,
      displayTitle: displayTitle,
      localizedTitle: localizedTitle,
      originalTitle: originalTitle,
      titleExtension: titleExtension,
      searchAliases: _normalizeStringList(searchAliases),
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
      coverDate: coverDate,
      releaseDate: releaseDate,
      releaseYear: releaseYear,
      barcode: barcode,
      variant: variant,
      crossover: crossover,
      plotSummary: plotSummary,
      plotDescription: plotDescription,
      creators: _normalizeMapList(creators),
      characters: _normalizeStringList(characters),
      characterDetails: _normalizeMapList(characterDetails),
      storyArcs: _normalizeStringList(storyArcs),
      editions: _normalizeEditionList(editions),
      genres: _normalizeStringList(genres),
      country: country,
      language: language,
      ageRating: ageRating,
      audienceRating: audienceRating,
      rawPlatforms: _normalizeStringList(rawPlatforms ?? game?.platforms),
      trailerUrls: _normalizeTrailerList(trailerUrls),
    );
    series = series == null ? null : _seriesOrNull(series);
    publishing = publishing == null ? null : _publishingOrNull(publishing);
    video = video == null ? null : _videoOrNull(video);
    music = music == null ? null : _musicOrNull(music);
    game = game == null ? null : _gameOrNull(game);

    switch (resolvedMediaKind) {
      case CatalogMediaKind.comic:
        return ComicCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case CatalogMediaKind.book:
        return BookCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case CatalogMediaKind.movie:
        return MovieCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case CatalogMediaKind.music:
        return MusicCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          music: music,
        );
      case CatalogMediaKind.game:
        return GameCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      case CatalogMediaKind.boardgame:
        return BoardGameCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      case CatalogMediaKind.unknown:
        return GenericCatalogItem._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
          music: music,
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
    final trailerLinks = (json['trailer_urls'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TrailerLink.fromJson)
            .toList(growable: false) ??
        const <TrailerLink>[];
    final externalLinks = (json['external_links'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((entry) => TrailerLink.fromJson({
                  ...entry,
                  if (entry['kind'] == null && entry['type'] == null)
                    'kind': 'external',
                }))
            .toList(growable: false) ??
        const <TrailerLink>[];

    final series = CatalogSeriesDetails(
      seriesId: json['series_id'] as String?,
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: (json['volume_number'] as num?)?.toDouble(),
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
      color: json['color'] as String?,
      nrDiscs: json['nr_discs'] as int?,
      screenRatio: json['screen_ratio'] as String?,
      audioTracks: json['audio_tracks'] as String?,
      subtitles: json['subtitles'] as String?,
      layers: json['layers'] as String?,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
    );
    final tracks = (json['tracks'] as List<dynamic>?)
        ?.map((track) => CatalogTrack.fromJson(track as Map<String, dynamic>))
        .toList(growable: false);
    final musicDiscs = (json['music_discs'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(CatalogDisc.fromJson)
        .toList(growable: false);
    final music = MusicCatalogDetails(
      trackCount: json['track_count'] as int?,
      tracks: tracks ?? const <CatalogTrack>[],
      discs: musicDiscs ?? const <CatalogDisc>[],
      catalogNumber: json['catalog_number'] as String?,
      releaseStatus: json['release_status'] as String?,
      originalReleaseDate: _parseDate(json['original_release_date'] as String?),
      recordingDate: _parseDate(json['recording_date'] as String?),
      studio: json['studio'] as String?,
      rpm: json['rpm'] as String?,
      spars: json['spars'] as String?,
      soundType: json['sound_type'] as String?,
      vinylColor: json['vinyl_color'] as String?,
      vinylWeight: json['vinyl_weight'] as String?,
      mediaCondition: json['media_condition'] as String?,
      instrument: json['instrument'] as String?,
      isLive: json['is_live'] as bool?,
      composition: json['composition'] as String?,
    );
    final rawPlatforms = (json['platforms'] as List<dynamic>?)
        ?.whereType<String>()
        .toList(growable: false);
    final game = GameCatalogDetails(
      platforms: rawPlatforms ?? const <String>[],
      toySubtype: json['toy_subtype'] as String?,
      toyType: json['toy_type'] as String?,
    );
    final publishing = CatalogPublishingDetails(
      pageCount: json['page_count'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      imprint: json['imprint'] as String?,
      subtitle: json['subtitle'] as String?,
      seriesGroup: json['series_group'] as String?,
      publicationPlace: json['publication_place'] as String?,
      originalCountry: json['original_country'] as String?,
      originalLanguage: json['original_language'] as String?,
      originalPublicationDate:
          _parseDate(json['original_publication_date'] as String?),
      originalPublicationPlace: json['original_publication_place'] as String?,
      originalPublisher: json['original_publisher'] as String?,
      paperType: json['paper_type'] as String?,
      printedBy: json['printed_by'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          (json['subject'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          ((json['subject'] as String?)?.trim().isNotEmpty == true
              ? <String>[(json['subject'] as String).trim()]
              : const <String>[]),
      dustJacketCondition: json['dust_jacket_condition'] as String?,
      dustJacket: json['dust_jacket'] as bool?,
      audiobookAbridged: json['audiobook_abridged'] as bool?,
      firstEdition: json['first_edition'] as bool?,
    );
    final editions = (json['editions'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(CatalogEdition.fromJson)
        .toList(growable: false);
    return CatalogItem(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      displayTitle: json['display_title'] as String?,
      localizedTitle: json['localized_title'] as String?,
      originalTitle: json['original_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      searchAliases: (json['search_aliases'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
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
      coverDate: _parseDate(json['cover_date'] as String?),
      releaseDate: _parseDate(json['release_date'] as String?),
      releaseYear: json['release_year'] as int?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
      crossover: json['crossover'] as String?,
      plotSummary: json['plot_summary'] as String?,
      plotDescription: json['plot_description'] as String?,
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
      characterDetails: (json['character_details'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .toList(growable: false),
      storyArcs: (json['story_arcs'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
      editions: editions,
      rawPlatforms: rawPlatforms,
      genres: (json['genres'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(growable: false),
      trailerUrls: [...trailerLinks, ...externalLinks],
      country: json['country'] as String?,
      language: json['language'] as String?,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
    );
  }

  final String id;
  final CatalogMediaKind mediaKind;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? titleExtension;
  final List<String>? searchAliases;
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
  final DateTime? coverDate;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final String? crossover;
  final String? plotSummary;
  final String? plotDescription;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<Map<String, dynamic>>? characterDetails;
  final List<String>? storyArcs;
  final List<CatalogEdition> editions;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<String>? rawPlatforms;
  final List<TrailerLink> trailerUrls;

  String get kind => mediaKind.apiValue;

  String get resolvedDisplayTitle {
    final display = displayTitle?.trim();
    if (display != null && display.isNotEmpty) {
      return display;
    }
    final localized = localizedTitle?.trim();
    if (localized != null && localized.isNotEmpty) {
      return localized;
    }
    final raw = title.trim();
    if (raw.isNotEmpty) {
      return raw;
    }
    final original = originalTitle?.trim();
    if (original != null && original.isNotEmpty) {
      return original;
    }
    return title;
  }

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
    final musicDiscs = music?.discs;
    final platforms = game?.platforms ?? rawPlatforms;
    return {
      'snapshot_version': 1,
      'kind': kind,
      'title': title,
      'display_title': displayTitle,
      'localized_title': localizedTitle,
      'original_title': originalTitle,
      'search_aliases': searchAliases,
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
      'cover_date': coverDate?.toUtc().toIso8601String(),
      'release_date': releaseDate?.toUtc().toIso8601String(),
      'release_year': releaseYear,
      'barcode': barcode,
      'variant': variant,
      'crossover': crossover,
      'plot_summary': plotSummary,
      'plot_description': plotDescription,
      'series_id': series?.seriesId,
      'series_title': series?.seriesTitle,
      'volume_name': series?.volumeName,
      'volume_number': series?.volumeNumber,
      'volume_start_year': series?.volumeStartYear,
      'season_number': series?.seasonNumber,
      'episode_number': series?.episodeNumber,
      'tags': series?.tags,
      'runtime_minutes': video?.runtimeMinutes,
      'color': video?.color,
      'nr_discs': video?.nrDiscs,
      'screen_ratio': video?.screenRatio,
      'audio_tracks': video?.audioTracks,
      'subtitles': video?.subtitles,
      'layers': video?.layers,
      'track_count': music?.trackCount,
      'tracks': tracks?.map((track) => track.toJson()).toList(growable: false),
      'music_discs':
          musicDiscs?.map((disc) => disc.toJson()).toList(growable: false),
      'catalog_number': music?.catalogNumber,
      'original_release_date':
          music?.originalReleaseDate?.toUtc().toIso8601String(),
      'recording_date': music?.recordingDate?.toUtc().toIso8601String(),
      'studio': music?.studio,
      'rpm': music?.rpm,
      'spars': music?.spars,
      'sound_type': music?.soundType,
      'vinyl_color': music?.vinylColor,
      'vinyl_weight': music?.vinylWeight,
      'media_condition': music?.mediaCondition,
      'instrument': music?.instrument,
      'is_live': music?.isLive,
      'composition': music?.composition,
      'editions':
          editions.map((edition) => edition.toJson()).toList(growable: false),
      'platforms': platforms,
      'toy_subtype': game?.toySubtype,
      'toy_type': game?.toyType,
      'creators': creators,
      'characters': characters,
      'character_details': characterDetails,
      'story_arcs': storyArcs,
      'genres': genres,
      'release_status': music?.releaseStatus,
      'country': country,
      'language': language,
      'age_rating': ageRating,
      'audience_rating': audienceRating,
      if (trailerUrls.any((link) => link.isTrailerLink))
        'trailer_urls': trailerUrls
            .where((link) => link.isTrailerLink)
            .map((t) => t.toJson())
            .toList(growable: false),
      if (trailerUrls.any((link) => link.isExternalLink))
        'external_links': trailerUrls
            .where((link) => link.isExternalLink)
            .map((link) => link.toJson())
            .toList(growable: false),
      'page_count': publishing?.pageCount,
      'cover_price_cents': publishing?.coverPriceCents,
      'currency': publishing?.currency,
      'imprint': publishing?.imprint,
      'subtitle': publishing?.subtitle,
      'series_group': publishing?.seriesGroup,
      'publication_place': publishing?.publicationPlace,
      'original_country': publishing?.originalCountry,
      'original_language': publishing?.originalLanguage,
      'original_publication_date':
          publishing?.originalPublicationDate?.toUtc().toIso8601String(),
      'original_publication_place': publishing?.originalPublicationPlace,
      'original_publisher': publishing?.originalPublisher,
      'paper_type': publishing?.paperType,
      'printed_by': publishing?.printedBy,
      'subjects': publishing?.subjects,
      'dust_jacket_condition': publishing?.dustJacketCondition,
      'dust_jacket': publishing?.dustJacket,
      'audiobook_abridged': publishing?.audiobookAbridged,
      'first_edition': publishing?.firstEdition,
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
          mediaKind: common.mediaKind,
          title: common.title,
          displayTitle: common.displayTitle,
          localizedTitle: common.localizedTitle,
          originalTitle: common.originalTitle,
          titleExtension: common.titleExtension,
          searchAliases: common.searchAliases,
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
          coverDate: common.coverDate,
          releaseDate: common.releaseDate,
          releaseYear: common.releaseYear,
          barcode: common.barcode,
          variant: common.variant,
          crossover: common.crossover,
          plotSummary: common.plotSummary,
          plotDescription: common.plotDescription,
          creators: common.creators,
          characters: common.characters,
          characterDetails: common.characterDetails,
          storyArcs: common.storyArcs,
          editions: common.editions ?? const <CatalogEdition>[],
          genres: common.genres,
          country: common.country,
          language: common.language,
          ageRating: common.ageRating,
          audienceRating: common.audienceRating,
          rawPlatforms: common.rawPlatforms,
          trailerUrls: common.trailerUrls ?? const <TrailerLink>[],
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
    required this.mediaKind,
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.titleExtension,
    this.searchAliases,
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
    this.coverDate,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.crossover,
    this.plotSummary,
    this.plotDescription,
    this.creators,
    this.characters,
    this.characterDetails,
    this.storyArcs,
    this.editions,
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.rawPlatforms,
    this.trailerUrls,
  });

  final String id;
  final CatalogMediaKind mediaKind;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? titleExtension;
  final List<String>? searchAliases;
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
  final DateTime? coverDate;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final String? crossover;
  final String? plotSummary;
  final String? plotDescription;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<Map<String, dynamic>>? characterDetails;
  final List<String>? storyArcs;
  final List<CatalogEdition>? editions;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<String>? rawPlatforms;
  final List<TrailerLink>? trailerUrls;
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

List<Map<String, dynamic>>? _normalizeMapList(
    List<Map<String, dynamic>>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<TrailerLink>? _normalizeTrailerList(List<TrailerLink>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}
