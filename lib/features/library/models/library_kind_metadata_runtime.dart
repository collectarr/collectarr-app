import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/foundation.dart';

abstract interface class LibraryKindMetadataRuntime {
  CatalogMediaKind get mediaKind;
  Map<String, dynamic> toSyncPayload();
}

@immutable
class GenericKindMetadataPayload implements LibraryKindMetadataRuntime {
  const GenericKindMetadataPayload({
    required this.mediaKind,
    this.itemNumber,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.coverDate,
    this.barcode,
    this.variant,
    this.crossover,
    this.plotSummary,
    this.plotDescription,
    this.series,
    this.video,
    this.music,
    this.game,
    this.publishing,
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
    this.boardGameStats,
    this.trailerUrls = const <TrailerLink>[],
  });

  @override
  final CatalogMediaKind mediaKind;
  final String? itemNumber;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? coverDate;
  final String? barcode;
  final String? variant;
  final String? crossover;
  final String? plotSummary;
  final String? plotDescription;
  final CatalogSeriesDetails? series;
  final VideoCatalogDetails? video;
  final MusicCatalogDetails? music;
  final GameCatalogDetails? game;
  final CatalogPublishingDetails? publishing;
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
  final BoardGameStatsDetails? boardGameStats;
  final List<TrailerLink> trailerUrls;

  @override
  Map<String, dynamic> toSyncPayload() {
    final series = this.series;
    final publishing = this.publishing;
    final video = this.video;
    final music = this.music;
    final game = this.game;
    final tracks = music?.tracks;
    final musicDiscs = music?.discs;
    final platforms = game?.platforms;
    return {
      'item_number': itemNumber,
      'edition_title': editionTitle,
      'physical_format': physicalFormat,
      'physical_format_label': physicalFormatLabel,
      'publisher': publisher,
      'cover_date': coverDate?.toUtc().toIso8601String(),
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
}
