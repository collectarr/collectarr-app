import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

final class LibraryMetadataItem {
  LibraryMetadataItem({
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
    List<CatalogEdition> editions = const <CatalogEdition>[],
    List<String>? genres,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
    BoardGameStatsDetails? boardGameStats,
    List<TrailerLink> trailerUrls = const <TrailerLink>[],
    LibraryItemIdentity? identity,
    LibraryCommonMetadata? common,
    LibraryKindMetadataRuntime? kindMetadata,
  })  : identity = identity ??
            LibraryItemIdentity(
              id: id,
              mediaKind: mediaKind ?? catalogMediaKindFromApiValue(kind),
            ),
        common = common ??
            LibraryCommonMetadata(
              title: title,
              displayTitle: displayTitle,
              localizedTitle: localizedTitle,
              originalTitle: originalTitle,
              titleExtension: titleExtension,
              searchAliases: searchAliases,
              sortKey: sortKey,
              synopsis: synopsis,
              coverImageUrl: coverImageUrl,
              thumbnailImageUrl: thumbnailImageUrl,
              coverImageData: coverImageData,
              releaseDate: releaseDate,
              releaseYear: releaseYear,
            ),
        kindMetadata = kindMetadata ??
            GenericKindMetadataPayload(
              mediaKind: mediaKind ?? catalogMediaKindFromApiValue(kind),
              itemNumber: itemNumber,
              editionTitle: editionTitle,
              physicalFormat: physicalFormat,
              physicalFormatLabel: physicalFormatLabel,
              publisher: publisher,
              coverDate: coverDate,
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
              genres: genres,
              country: country,
              language: language,
              ageRating: ageRating,
              audienceRating: audienceRating,
              boardGameStats: boardGameStats,
              trailerUrls: trailerUrls,
            );

  static const _unset = Object();

  final LibraryItemIdentity identity;
  final LibraryCommonMetadata common;
  final LibraryKindMetadataRuntime kindMetadata;

  GenericKindMetadataPayload get _payload =>
      kindMetadata is GenericKindMetadataPayload
          ? kindMetadata as GenericKindMetadataPayload
          : GenericKindMetadataPayload(mediaKind: identity.mediaKind);

  String get id => identity.id;
  CatalogMediaKind get mediaKind => identity.mediaKind;
  String get kind => identity.kind;

  String get title => common.title;
  String? get displayTitle => common.displayTitle;
  String? get localizedTitle => common.localizedTitle;
  String? get originalTitle => common.originalTitle;
  String? get titleExtension => common.titleExtension;
  List<String>? get searchAliases => common.searchAliases;
  String? get sortKey => common.sortKey;
  String? get synopsis => common.synopsis;
  String? get coverImageUrl => common.coverImageUrl;
  String? get thumbnailImageUrl => common.thumbnailImageUrl;
  String? get coverImageData => common.coverImageData;
  DateTime? get releaseDate => common.releaseDate;
  int? get releaseYear => common.releaseYear;

  String get resolvedDisplayTitle => common.resolvedDisplayTitle;
  String? get displayCoverUrl => common.displayCoverUrl;

  String? get itemNumber => _payload.itemNumber;
  String? get editionTitle => _payload.editionTitle;
  String? get physicalFormat => _payload.physicalFormat;
  String? get physicalFormatLabel => _payload.physicalFormatLabel;
  String? get publisher => _payload.publisher;
  DateTime? get coverDate => _payload.coverDate;
  String? get barcode => _payload.barcode;
  String? get variant => _payload.variant;
  String? get crossover => _payload.crossover;
  String? get plotSummary => _payload.plotSummary;
  String? get plotDescription => _payload.plotDescription;
  CatalogSeriesDetails? get series => _payload.series;
  VideoCatalogDetails? get video => _payload.video;
  MusicCatalogDetails? get music => _payload.music;
  GameCatalogDetails? get game => _payload.game;
  CatalogPublishingDetails? get publishing => _payload.publishing;
  List<Map<String, dynamic>>? get creators => _payload.creators;
  List<String>? get characters => _payload.characters;
  List<Map<String, dynamic>>? get characterDetails => _payload.characterDetails;
  List<String>? get storyArcs => _payload.storyArcs;
  List<CatalogEdition> get editions => _payload.editions;
  List<String>? get genres => _payload.genres;
  String? get country => _payload.country;
  String? get language => _payload.language;
  String? get ageRating => _payload.ageRating;
  String? get audienceRating => _payload.audienceRating;
  BoardGameStatsDetails? get boardGameStats => _payload.boardGameStats;
  List<TrailerLink> get trailerUrls => _payload.trailerUrls;
  String? get displayEditionLabel =>
      physicalFormatLabel ?? variant ?? editionTitle;

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
      boardGameStats: item.boardGameStats,
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
    Object? boardGameStats = _unset,
    List<TrailerLink>? trailerUrls,
  }) {
    final newMediaKind = mediaKind ??
        (kind != null ? catalogMediaKindFromApiValue(kind) : this.mediaKind);
    return LibraryMetadataItem(
      id: id ?? this.id,
      mediaKind: newMediaKind,
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
      boardGameStats: identical(boardGameStats, _unset)
          ? this.boardGameStats
          : boardGameStats as BoardGameStatsDetails?,
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
      boardGameStats: boardGameStats,
      trailerUrls: trailerUrls,
    );
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'snapshot_version': 1,
      'kind': kind,
      'title': title,
      'display_title': displayTitle,
      'localized_title': localizedTitle,
      'original_title': originalTitle,
      'search_aliases': searchAliases,
      'sort_key': sortKey,
      'synopsis': synopsis,
      'cover_image_url': coverImageUrl,
      'thumbnail_image_url': thumbnailImageUrl,
      if (coverImageData != null) 'cover_image_data': coverImageData,
      'release_date': releaseDate?.toUtc().toIso8601String(),
      'release_year': releaseYear,
      ...kindMetadata.toSyncPayload(),
    };
  }
}
