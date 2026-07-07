import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

final class AnimeEpisode {
  const AnimeEpisode({
    required this.id,
    required this.title,
    this.episodeNumber,
    this.seasonNumber,
    this.releaseDate,
    this.barcode,
    this.formatLabel,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.isPrimary = false,
  });

  final String id;
  final String title;
  final String? episodeNumber;
  final String? seasonNumber;
  final DateTime? releaseDate;
  final String? barcode;
  final String? formatLabel;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final bool isPrimary;

  factory AnimeEpisode.fromDtoValue(Object? value, {bool isPrimary = false}) {
    final json = value is Map<String, dynamic> ? value : const <String, dynamic>{};
    return AnimeEpisode(
      id: _stringOrEmpty(json['id'] ?? json['episode_id'] ?? json['episodeId']),
      title: _stringOrNull(json['title']) ?? 'Episode',
      episodeNumber: _stringOrNull(json['episode_number'] ?? json['episodeNumber']),
      seasonNumber: _stringOrNull(json['season_number'] ?? json['seasonNumber']),
      releaseDate: _dateOrNull(json['release_date'] ?? json['releaseDate']),
      barcode: _stringOrNull(json['barcode']),
      formatLabel: _stringOrNull(json['format_label'] ?? json['formatLabel']),
      coverImageUrl:
          _stringOrNull(json['cover_image_url'] ?? json['coverImageUrl']),
      thumbnailImageUrl:
          _stringOrNull(json['thumbnail_image_url'] ?? json['thumbnailImageUrl']),
      isPrimary: isPrimary,
    );
  }

  factory AnimeEpisode.fromCatalogEdition(
    CatalogEdition edition, {
    bool isPrimary = false,
  }) {
    return AnimeEpisode(
      id: edition.id,
      title: edition.title,
      releaseDate: edition.releaseDate,
      barcode: edition.upc ?? edition.isbn,
      formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
      isPrimary: isPrimary,
    );
  }

  CatalogEdition toCatalogEdition() {
    return CatalogEdition(
      id: id,
      title: title,
      releaseDate: releaseDate,
      upc: barcode,
      physicalFormat: formatLabel,
      physicalFormatLabel: formatLabel,
    );
  }
}

final class AnimePersonalOverlay {
  const AnimePersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
    this.lastWatchedAt,
    this.watchedWhere,
    this.ownedStatus,
  });

  factory AnimePersonalOverlay.fromShelf(ShelfEntry source) {
    return AnimePersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
      lastWatchedAt: source.trackingEntry?.updatedAt ?? source.ownedItem?.updatedAt,
      watchedWhere: source.ownedItem?.storageDevice,
      ownedStatus: source.ownedItem?.collectionStatus,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;
  final DateTime? lastWatchedAt;
  final String? watchedWhere;
  final String? ownedStatus;
}

final class AnimeSeries {
  const AnimeSeries({
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
    this.video,
    this.episodes = const <AnimeEpisode>[],
    this.trailerUrls = const <TrailerLink>[],
    this.plotSummary,
    this.plotDescription,
    this.creators,
    this.characters = const <String>[],
    this.storyArcs = const <String>[],
    this.genres = const <String>[],
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.originalLanguage,
    this.sortTitle,
    this.status,
    this.endDate,
    this.episodeCount,
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
  final VideoCatalogDetails? video;
  final List<AnimeEpisode> episodes;
  final List<TrailerLink> trailerUrls;
  final String? plotSummary;
  final String? plotDescription;
  final List<Map<String, dynamic>>? creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final String? originalLanguage;
  final String? sortTitle;
  final String? status;
  final DateTime? endDate;
  final int? episodeCount;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  String? get displayEpisodeLabel =>
      variant ?? (episodes.isNotEmpty ? episodes.first.title : null);

  bool get hasMissingCoreMetadata =>
      publisher == null &&
      releaseDate == null &&
      releaseYear == null &&
      displayCoverUrl == null &&
      displayEpisodeLabel == null;

  factory AnimeSeries.fromDto(AnimeSeriesDto dto) {
    return AnimeSeries(
      id: dto.id,
      title: dto.title,
      synopsis: dto.description,
      releaseDate: dto.releaseDate,
      releaseYear: dto.releaseDate?.year,
      originalLanguage: dto.originalLanguage,
      sortTitle: dto.sortTitle,
      status: dto.status,
      endDate: dto.endDate,
      episodeCount: dto.episodeCount,
      episodes: [
        for (var index = 0; index < dto.episodes.length; index++)
          AnimeEpisode.fromDtoValue(
            dto.episodes[index],
            isPrimary: index == 0,
          ),
      ],
      series: _seriesFromRaw(dto.raw),
      video: _videoFromRaw(dto.raw),
      searchAliases: const <String>[],
      characters: const <String>[],
      storyArcs: const <String>[],
      genres: const <String>[],
    );
  }

  factory AnimeSeries.fromMetadataItem(LibraryMetadataItem item) {
    final episodes = [
      for (var index = 0; index < item.editions.length; index++)
        AnimeEpisode.fromCatalogEdition(
          item.editions[index],
          isPrimary: index == 0,
        ),
    ];
    return AnimeSeries(
      id: item.id,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      searchAliases: item.searchAliases ?? const <String>[],
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
      video: item.video,
      episodes: episodes,
      trailerUrls: item.trailerUrls,
      plotSummary: item.plotSummary,
      plotDescription: item.plotDescription,
      creators: item.creators,
      characters: item.characters ?? const <String>[],
      storyArcs: item.storyArcs ?? const <String>[],
      genres: item.genres ?? const <String>[],
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
      audienceRating: item.audienceRating,
      originalLanguage: item.language,
      sortTitle: item.sortKey,
      status: item.video?.layers,
      episodeCount: item.series?.episodeNumber,
    );
  }
}

CatalogSeriesDetails? _seriesFromRaw(Map<String, dynamic> raw) {
  final details = CatalogSeriesDetails(
    seriesId: _stringOrNull(raw['series_id'] ?? raw['seriesId']),
    seriesTitle: _stringOrNull(raw['series_title'] ?? raw['seriesTitle']),
    seasonNumber: _intOrNull(raw['season_number'] ?? raw['seasonNumber']),
    episodeNumber: _intOrNull(raw['episode_number'] ?? raw['episodeNumber']),
    tags: _stringList(raw['tags']),
  );
  return details.hasData ? details : null;
}

VideoCatalogDetails? _videoFromRaw(Map<String, dynamic> raw) {
  final details = VideoCatalogDetails(
    runtimeMinutes: _intOrNull(raw['runtime_minutes'] ?? raw['runtimeMinutes']),
    ageRating: _stringOrNull(raw['age_rating'] ?? raw['ageRating']),
    audienceRating: _stringOrNull(
      raw['audience_rating'] ?? raw['audienceRating'],
    ),
  );
  return details.hasData ? details : null;
}

String _stringOrEmpty(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? '' : text;
}

String? _stringOrNull(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return [
    for (final entry in value)
      if (entry != null && entry.toString().trim().isNotEmpty)
        entry.toString().trim(),
  ];
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _dateOrNull(Object? value) {
  final text = _stringOrNull(value);
  return text == null ? null : DateTime.tryParse(text);
}
