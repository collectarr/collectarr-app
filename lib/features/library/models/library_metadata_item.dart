import 'package:collectarr_app/core/models/catalog_item.dart';

class LibraryMetadataItem {
    LibraryMetadataItem({
    required this.id,
        String? kind,
        CatalogMediaKind? mediaKind,
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
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
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.series,
    this.video,
    this.music,
    this.game,
    this.publishing,
    this.creators,
    this.characters,
    this.storyArcs,
    this.editions = const <CatalogEdition>[],
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    }) : mediaKind = mediaKind ?? catalogMediaKindFromApiValue(kind);

  static const _unset = Object();

  final String id;
    final CatalogMediaKind mediaKind;
  final String title;
    final String? displayTitle;
    final String? localizedTitle;
    final String? originalTitle;
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
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final CatalogSeriesDetails? series;
  final VideoCatalogDetails? video;
  final MusicCatalogDetails? music;
  final GameCatalogDetails? game;
  final CatalogPublishingDetails? publishing;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
    final List<CatalogEdition> editions;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;

    String get kind => mediaKind.apiValue;

  factory LibraryMetadataItem.fromCatalogItem(CatalogItem item) {
    return LibraryMetadataItem(
      id: item.id,
            mediaKind: item.mediaKind,
      title: item.title,
    displayTitle: item.displayTitle,
    localizedTitle: item.localizedTitle,
    originalTitle: item.originalTitle,
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
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      barcode: item.barcode,
      variant: item.variant,
      series: item.series,
      video: item.video,
      music: item.music,
      game: item.game,
      publishing: item.publishing,
      creators: item.creators,
      characters: item.characters,
      storyArcs: item.storyArcs,
    editions: item.editions,
      genres: item.genres,
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
    );
  }

  LibraryMetadataItem copyWith({
    String? id,
    String? kind,
        CatalogMediaKind? mediaKind,
    String? title,
    Object? displayTitle = _unset,
    Object? localizedTitle = _unset,
    Object? originalTitle = _unset,
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
    Object? releaseDate = _unset,
    Object? releaseYear = _unset,
    Object? barcode = _unset,
    Object? variant = _unset,
    Object? series = _unset,
    Object? video = _unset,
    Object? music = _unset,
    Object? game = _unset,
    Object? publishing = _unset,
    Object? creators = _unset,
    Object? characters = _unset,
    Object? storyArcs = _unset,
    Object? editions = _unset,
    Object? genres = _unset,
    Object? country = _unset,
    Object? language = _unset,
    Object? ageRating = _unset,
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
      searchAliases: identical(searchAliases, _unset)
          ? this.searchAliases
          : searchAliases as List<String>?,
      sortKey: identical(sortKey, _unset) ? this.sortKey : sortKey as String?,
      itemNumber: identical(itemNumber, _unset)
          ? this.itemNumber
          : itemNumber as String?,
      synopsis: identical(synopsis, _unset)
          ? this.synopsis
          : synopsis as String?,
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
      publisher: identical(publisher, _unset)
          ? this.publisher
          : publisher as String?,
      releaseDate: identical(releaseDate, _unset)
          ? this.releaseDate
          : releaseDate as DateTime?,
      releaseYear: identical(releaseYear, _unset)
          ? this.releaseYear
          : releaseYear as int?,
      barcode: identical(barcode, _unset)
          ? this.barcode
          : barcode as String?,
      variant: identical(variant, _unset)
          ? this.variant
          : variant as String?,
      series: identical(series, _unset)
          ? this.series
          : series as CatalogSeriesDetails?,
      video: identical(video, _unset)
          ? this.video
          : video as VideoCatalogDetails?,
      music: identical(music, _unset)
          ? this.music
          : music as MusicCatalogDetails?,
      game: identical(game, _unset)
          ? this.game
          : game as GameCatalogDetails?,
      publishing: identical(publishing, _unset)
          ? this.publishing
          : publishing as CatalogPublishingDetails?,
      creators: identical(creators, _unset)
          ? this.creators
          : creators as List<Map<String, dynamic>>?,
      characters: identical(characters, _unset)
          ? this.characters
          : characters as List<String>?,
      storyArcs: identical(storyArcs, _unset)
          ? this.storyArcs
          : storyArcs as List<String>?,
      editions: identical(editions, _unset)
          ? this.editions
          : editions as List<CatalogEdition>,
      genres: identical(genres, _unset)
          ? this.genres
          : genres as List<String>?,
      country: identical(country, _unset)
          ? this.country
          : country as String?,
      language: identical(language, _unset)
          ? this.language
          : language as String?,
      ageRating: identical(ageRating, _unset)
          ? this.ageRating
          : ageRating as String?,
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
      releaseDate: releaseDate,
      releaseYear: releaseYear,
      barcode: barcode,
      variant: variant,
            series: series,
            video: video,
            music: music,
            game: game,
            publishing: publishing,
      creators: creators,
      characters: characters,
      storyArcs: storyArcs,
    editions: editions,
            rawPlatforms:
                    platformList != null && platformList.isNotEmpty ? platformList : null,
      genres: genres,
      country: country,
      language: language,
      ageRating: ageRating,
    );
  }

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;
  String? get displayEditionLabel =>
      physicalFormatLabel ?? variant ?? editionTitle;
}