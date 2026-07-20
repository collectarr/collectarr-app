import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/video_catalog_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/music_catalog_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/game_catalog_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/boardgame_stats_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';

class TrailerLinkDto {
  const TrailerLinkDto({
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

  factory TrailerLinkDto.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? json['type'])?.toString().toLowerCase();
    final source = json['source'] as String?;
    final inferredKind = rawKind ??
        ((source?.toLowerCase().contains('external') ?? false)
            ? 'external'
            : 'trailer');
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    return TrailerLinkDto(
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

sealed class CatalogItemDto {
  const CatalogItemDto._({
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
    this.editions = const <CatalogEditionDto>[],
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.rawPlatforms,
    this.boardGameStats,
    this.trailerUrls = const <TrailerLinkDto>[],
  });

  factory CatalogItemDto({
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
    CatalogSeriesDetailsDto? series,
    VideoCatalogDetailsDto? video,
    MusicCatalogDetailsDto? music,
    GameCatalogDetailsDto? game,
    CatalogPublishingDetailsDto? publishing,
    List<Map<String, dynamic>>? creators,
    List<String>? characters,
    List<Map<String, dynamic>>? characterDetails,
    List<String>? storyArcs,
    List<String>? rawPlatforms,
    BoardGameStatsDetailsDto? boardGameStats,
    List<TrailerLinkDto>? trailerUrls,
    List<String>? genres,
    List<CatalogEditionDto>? editions,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
  }) {
    final resolvedMediaKind = mediaKind ?? catalogMediaKindFromApiValue(kind);
    final common = _CatalogItemCommonDto(
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
      boardGameStats: boardGameStats,
      trailerUrls: _normalizeTrailerList(trailerUrls),
    );
    series = series == null ? null : _seriesOrNull(series);
    publishing = publishing == null ? null : _publishingOrNull(publishing);
    video = video == null ? null : _videoOrNull(video);
    music = music == null ? null : _musicOrNull(music);
    game = game == null ? null : _gameOrNull(game);

    switch (resolvedMediaKind) {
      case CatalogMediaKind.comic:
        return ComicCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case CatalogMediaKind.book:
        return BookCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case CatalogMediaKind.movie:
        return MovieCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case CatalogMediaKind.music:
        return MusicCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
          music: music,
        );
      case CatalogMediaKind.game:
        return GameCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      case CatalogMediaKind.boardgame:
        return BoardGameCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      case CatalogMediaKind.unknown:
        return GenericCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
          music: music,
          game: game,
        );
      default:
        return GenericCatalogItemDto._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
          music: music,
          game: game,
        );
    }
  }

  factory CatalogItemDto.fromJson(Map<String, dynamic> json) {
    final trailerLinks = (json['trailer_urls'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TrailerLinkDto.fromJson)
            .toList(growable: false) ??
        const <TrailerLinkDto>[];
    final externalLinks = (json['external_links'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((entry) => TrailerLinkDto.fromJson({
                  ...entry,
                  if (entry['kind'] == null && entry['type'] == null)
                    'kind': 'external',
                }))
            .toList(growable: false) ??
        const <TrailerLinkDto>[];

    final series = CatalogSeriesDetailsDto.fromJson(
      Map<String, dynamic>.from(json['series'] as Map? ?? {}),
    );
    final video = VideoCatalogDetailsDto(
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
        ?.map((track) => CatalogTrackDto.fromJson(track as Map<String, dynamic>))
        .toList(growable: false);
    final musicDiscs = (json['music_discs'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(CatalogDiscDto.fromJson)
        .toList(growable: false);
    final music = MusicCatalogDetailsDto(
      trackCount: json['track_count'] as int?,
      tracks: tracks ?? const <CatalogTrackDto>[],
      discs: musicDiscs ?? const <CatalogDiscDto>[],
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
    final game = GameCatalogDetailsDto(
      platforms: rawPlatforms ?? const <String>[],
      toySubtype: json['toy_subtype'] as String?,
      toyType: json['toy_type'] as String?,
    );
    final boardGameStats = BoardGameStatsDetailsDto.fromJson(json);
    final publishing = CatalogPublishingDetailsDto(
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
        .map(CatalogEditionDto.fromJson)
        .toList(growable: false);
    return CatalogItemDto(
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
      boardGameStats: boardGameStats.hasData ? boardGameStats : null,
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
  final List<CatalogEditionDto> editions;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<String>? rawPlatforms;
  final BoardGameStatsDetailsDto? boardGameStats;
  final List<TrailerLinkDto> trailerUrls;

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

  CatalogSeriesDetailsDto? get series;
  CatalogPublishingDetailsDto? get publishing;
  VideoCatalogDetailsDto? get video;
  MusicCatalogDetailsDto? get music;
  GameCatalogDetailsDto? get game;

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
      if (boardGameStats != null) ...boardGameStats!.toJson(),
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

abstract base class _TypedCatalogItemDto extends CatalogItemDto {
  _TypedCatalogItemDto._({
    required _CatalogItemCommonDto common,
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
          editions: common.editions ?? const <CatalogEditionDto>[],
          genres: common.genres,
          country: common.country,
          language: common.language,
          ageRating: common.ageRating,
          audienceRating: common.audienceRating,
          rawPlatforms: common.rawPlatforms,
          boardGameStats: common.boardGameStats,
          trailerUrls: common.trailerUrls ?? const <TrailerLinkDto>[],
        );

  final CatalogSeriesDetailsDto? seriesDetails;
  final CatalogPublishingDetailsDto? publishingDetails;
  final VideoCatalogDetailsDto? videoDetails;
  final MusicCatalogDetailsDto? musicDetails;
  final GameCatalogDetailsDto? gameDetails;

  @override
  CatalogSeriesDetailsDto? get series => seriesDetails;

  @override
  CatalogPublishingDetailsDto? get publishing => publishingDetails;

  @override
  VideoCatalogDetailsDto? get video => videoDetails;

  @override
  MusicCatalogDetailsDto? get music => musicDetails;

  @override
  GameCatalogDetailsDto? get game => gameDetails;
}

final class ComicCatalogItemDto extends _TypedCatalogItemDto {
  ComicCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MangaCatalogItemDto extends _TypedCatalogItemDto {
  MangaCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class BookCatalogItemDto extends _TypedCatalogItemDto {
  BookCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MovieCatalogItemDto extends _TypedCatalogItemDto {
  MovieCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    VideoCatalogDetailsDto? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class TvCatalogItemDto extends _TypedCatalogItemDto {
  TvCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    VideoCatalogDetailsDto? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class AnimeCatalogItemDto extends _TypedCatalogItemDto {
  AnimeCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    VideoCatalogDetailsDto? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class MusicCatalogItemDto extends _TypedCatalogItemDto {
  MusicCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    MusicCatalogDetailsDto? music,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          musicDetails: music,
        );
}

final class GameCatalogItemDto extends _TypedCatalogItemDto {
  GameCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    GameCatalogDetailsDto? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class BoardGameCatalogItemDto extends _TypedCatalogItemDto {
  BoardGameCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    GameCatalogDetailsDto? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class GenericCatalogItemDto extends _TypedCatalogItemDto {
  GenericCatalogItemDto._({
    required _CatalogItemCommonDto common,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    VideoCatalogDetailsDto? video,
    MusicCatalogDetailsDto? music,
    GameCatalogDetailsDto? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
          musicDetails: music,
          gameDetails: game,
        );
}

class _CatalogItemCommonDto {
  const _CatalogItemCommonDto({
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
    this.boardGameStats,
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
  final List<CatalogEditionDto>? editions;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<String>? rawPlatforms;
  final BoardGameStatsDetailsDto? boardGameStats;
  final List<TrailerLinkDto>? trailerUrls;
}

CatalogSeriesDetailsDto? _seriesOrNull(CatalogSeriesDetailsDto details) {
  return details.hasData ? details : null;
}

CatalogPublishingDetailsDto? _publishingOrNull(CatalogPublishingDetailsDto details) {
  return details.hasData ? details : null;
}

VideoCatalogDetailsDto? _videoOrNull(VideoCatalogDetailsDto details) {
  return details.hasData ? details : null;
}

MusicCatalogDetailsDto? _musicOrNull(MusicCatalogDetailsDto details) {
  return details.hasData ? details : null;
}

GameCatalogDetailsDto? _gameOrNull(GameCatalogDetailsDto details) {
  return details.hasData ? details : null;
}

List<String>? _normalizeStringList(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<CatalogEditionDto>? _normalizeEditionList(List<CatalogEditionDto>? values) {
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

List<TrailerLinkDto>? _normalizeTrailerList(List<TrailerLinkDto>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}
