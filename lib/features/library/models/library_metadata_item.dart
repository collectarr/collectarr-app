import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

class LibraryMetadataItem {
  LibraryMetadataItem({
    required this.id,
    String? kind,
    CatalogMediaKind? mediaKind,
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
    this.trailerUrls = const <TrailerLink>[],
  }) : mediaKind = mediaKind ?? catalogMediaKindFromApiValue(kind);

  static const _unset = Object();

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
  final List<TrailerLink> trailerUrls;

  String get kind => mediaKind.apiValue;

  String get resolvedDisplayTitle =>
      displayTitle ?? localizedTitle ?? originalTitle ?? title;

  factory LibraryMetadataItem.fromCatalogItem(CatalogItem item) {
    return LibraryMetadataItem(
      id: item.id,
      mediaKind: item.mediaKind,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      titleExtension: item.titleExtension,
      searchAliases: item.searchAliases,
      sortKey: item.sortKey,
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
      coverImageData: item.coverImageData,
      editionTitle: item.editionTitle,
      physicalFormat: item.physicalFormat,
      physicalFormatLabel: item.physicalFormatLabel,
      publisher: item.publisher,
      coverDate: item.coverDate,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      barcode: item.barcode,
      variant: item.variant,
      crossover: item.crossover,
      plotSummary: item.plotSummary,
      plotDescription: item.plotDescription,
      series: item.series,
      video: item.video,
      music: item.music,
      game: item.game,
      publishing: item.publishing,
      creators: item.creators,
      characters: item.characters,
      characterDetails: item.characterDetails,
      storyArcs: item.storyArcs,
      editions: item.editions,
      genres: item.genres,
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
      audienceRating: item.audienceRating,
      trailerUrls: item.trailerUrls,
    );
  }

  factory LibraryMetadataItem.fromMetadataMap(Map<String, dynamic> json) {
    return LibraryMetadataItem.fromCatalogItem(CatalogItem.fromJson(json));
  }

  LibraryMetadataItem copyWith({
    String? id,
    String? kind,
    CatalogMediaKind? mediaKind,
    String? title,
    Object? displayTitle = _unset,
    Object? localizedTitle = _unset,
    Object? originalTitle = _unset,
    Object? titleExtension = _unset,
    Object? searchAliases = _unset,
    Object? sortKey = _unset,
    Object? itemNumber = _unset,
    Object? synopsis = _unset,
    Object? coverImageUrl = _unset,
    Object? thumbnailImageUrl = _unset,
    Object? coverImageData = _unset,
    Object? editionTitle = _unset,
    Object? physicalFormat = _unset,
    Object? physicalFormatLabel = _unset,
    Object? publisher = _unset,
    Object? coverDate = _unset,
    Object? releaseDate = _unset,
    Object? releaseYear = _unset,
    Object? barcode = _unset,
    Object? variant = _unset,
    Object? crossover = _unset,
    Object? plotSummary = _unset,
    Object? plotDescription = _unset,
    Object? series = _unset,
    Object? video = _unset,
    Object? music = _unset,
    Object? game = _unset,
    Object? publishing = _unset,
    Object? creators = _unset,
    Object? characters = _unset,
    Object? characterDetails = _unset,
    Object? storyArcs = _unset,
    Object? editions = _unset,
    Object? genres = _unset,
    Object? country = _unset,
    Object? language = _unset,
    Object? ageRating = _unset,
    Object? audienceRating = _unset,
    List<TrailerLink>? trailerUrls,
  }) {
    return LibraryMetadataItem(
      id: id ?? this.id,
      mediaKind: mediaKind ??
          (kind != null ? catalogMediaKindFromApiValue(kind) : this.mediaKind),
      title: title ?? this.title,
      displayTitle: identical(displayTitle, _unset)
          ? this.displayTitle
          : displayTitle as String?,
      localizedTitle: identical(localizedTitle, _unset)
          ? this.localizedTitle
          : localizedTitle as String?,
      originalTitle: identical(originalTitle, _unset)
          ? this.originalTitle
          : originalTitle as String?,
      titleExtension: identical(titleExtension, _unset)
          ? this.titleExtension
          : titleExtension as String?,
      searchAliases: identical(searchAliases, _unset)
          ? this.searchAliases
          : searchAliases as List<String>?,
      sortKey: identical(sortKey, _unset) ? this.sortKey : sortKey as String?,
      itemNumber: identical(itemNumber, _unset)
          ? this.itemNumber
          : itemNumber as String?,
      synopsis:
          identical(synopsis, _unset) ? this.synopsis : synopsis as String?,
      coverImageUrl: identical(coverImageUrl, _unset)
          ? this.coverImageUrl
          : coverImageUrl as String?,
      thumbnailImageUrl: identical(thumbnailImageUrl, _unset)
          ? this.thumbnailImageUrl
          : thumbnailImageUrl as String?,
      coverImageData: identical(coverImageData, _unset)
          ? this.coverImageData
          : coverImageData as String?,
      editionTitle: identical(editionTitle, _unset)
          ? this.editionTitle
          : editionTitle as String?,
      physicalFormat: identical(physicalFormat, _unset)
          ? this.physicalFormat
          : physicalFormat as String?,
      physicalFormatLabel: identical(physicalFormatLabel, _unset)
          ? this.physicalFormatLabel
          : physicalFormatLabel as String?,
      publisher:
          identical(publisher, _unset) ? this.publisher : publisher as String?,
      coverDate: identical(coverDate, _unset)
          ? this.coverDate
          : coverDate as DateTime?,
      releaseDate: identical(releaseDate, _unset)
          ? this.releaseDate
          : releaseDate as DateTime?,
      releaseYear: identical(releaseYear, _unset)
          ? this.releaseYear
          : releaseYear as int?,
      barcode: identical(barcode, _unset) ? this.barcode : barcode as String?,
      variant: identical(variant, _unset) ? this.variant : variant as String?,
      crossover:
          identical(crossover, _unset) ? this.crossover : crossover as String?,
      plotSummary: identical(plotSummary, _unset)
          ? this.plotSummary
          : plotSummary as String?,
      plotDescription: identical(plotDescription, _unset)
          ? this.plotDescription
          : plotDescription as String?,
      series: identical(series, _unset)
          ? this.series
          : series as CatalogSeriesDetails?,
      video:
          identical(video, _unset) ? this.video : video as VideoCatalogDetails?,
      music:
          identical(music, _unset) ? this.music : music as MusicCatalogDetails?,
      game: identical(game, _unset) ? this.game : game as GameCatalogDetails?,
      publishing: identical(publishing, _unset)
          ? this.publishing
          : publishing as CatalogPublishingDetails?,
      creators: identical(creators, _unset)
          ? this.creators
          : creators as List<Map<String, dynamic>>?,
      characters: identical(characters, _unset)
          ? this.characters
          : characters as List<String>?,
      characterDetails: identical(characterDetails, _unset)
          ? this.characterDetails
          : characterDetails as List<Map<String, dynamic>>?,
      storyArcs: identical(storyArcs, _unset)
          ? this.storyArcs
          : storyArcs as List<String>?,
      editions: identical(editions, _unset)
          ? this.editions
          : editions as List<CatalogEdition>,
      genres: identical(genres, _unset) ? this.genres : genres as List<String>?,
      country: identical(country, _unset) ? this.country : country as String?,
      language:
          identical(language, _unset) ? this.language : language as String?,
      ageRating:
          identical(ageRating, _unset) ? this.ageRating : ageRating as String?,
      audienceRating: identical(audienceRating, _unset)
          ? this.audienceRating
          : audienceRating as String?,
      trailerUrls: trailerUrls ?? this.trailerUrls,
    );
  }

  CatalogItem toCatalogItem() {
    final platformList = game?.platforms;
    return CatalogItem(
      id: id,
      mediaKind: mediaKind,
      title: title,
      displayTitle: displayTitle,
      localizedTitle: localizedTitle,
      originalTitle: originalTitle,
      titleExtension: titleExtension,
      searchAliases: searchAliases,
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
      series: series,
      video: video,
      music: music,
      game: game,
      publishing: publishing,
      creators: creators,
      characters: characters,
      characterDetails: characterDetails,
      storyArcs: storyArcs,
      editions: editions,
      rawPlatforms:
          platformList != null && platformList.isNotEmpty ? platformList : null,
      genres: genres,
      country: country,
      language: language,
      ageRating: ageRating,
      audienceRating: audienceRating,
      trailerUrls: trailerUrls,
    );
  }

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;
  String? get displayEditionLabel =>
      physicalFormatLabel ?? variant ?? editionTitle;

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
}
