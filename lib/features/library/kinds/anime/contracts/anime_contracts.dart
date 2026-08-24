import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AnimeCatalog {
  const AnimeCatalog({
    required this.identity,
    required this.title,
    this.nativeTitle,
    this.romajiTitle,
    this.englishTitle,
    this.alternateTitles = const [],
    this.format = AnimeFormat.tv,
    this.season,
    this.seasonYear,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    this.airingStatus = AnimeAiringStatus.finished,
    this.startDate,
    this.endDate,
    this.studios = const [],
    this.producers = const [],
    this.licensors = const [],
    this.sourceMaterial = AnimeSource.manga,
    this.genres = const [],
    this.themes = const [],
    this.country = 'JP',
    this.language = 'ja',
    this.relations = const [],
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? nativeTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final List<String> alternateTitles;
  final AnimeFormat format;
  final AnimeSeason? season;
  final int? seasonYear;
  final int? episodeCount;
  final int? episodeRuntimeMinutes;
  final AnimeAiringStatus airingStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> studios;
  final List<String> producers;
  final List<String> licensors;
  final AnimeSource sourceMaterial;
  final List<String> genres;
  final List<String> themes;
  final String country;
  final String language;
  final List<AnimeRelation> relations;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.anime;
  String? get studio => studios.firstOrNull;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory AnimeCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.anime,
    );

    return AnimeCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      nativeTitle: json['native_title'] as String?,
      romajiTitle: json['romaji_title'] as String?,
      englishTitle: json['english_title'] as String?,
      alternateTitles: (json['alternate_titles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      format: AnimeFormat.fromString(json['format'] as String?),
      season: json['season'] != null
          ? AnimeSeason.fromString(json['season'] as String)
          : null,
      seasonYear: json['season_year'] as int?,
      episodeCount: json['episode_count'] as int?,
      episodeRuntimeMinutes: json['episode_runtime_minutes'] as int?,
      airingStatus:
          AnimeAiringStatus.fromString(json['airing_status'] as String?),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      studios: (json['studios'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      producers: (json['producers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      licensors: (json['licensors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sourceMaterial:
          AnimeSource.fromString(json['source_material'] as String?),
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      country: (json['country'] as String?) ?? 'JP',
      language: (json['language'] as String?) ?? 'ja',
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => AnimeRelation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'anime',
        'title': title,
        if (nativeTitle != null) 'native_title': nativeTitle,
        if (romajiTitle != null) 'romaji_title': romajiTitle,
        if (englishTitle != null) 'english_title': englishTitle,
        if (alternateTitles.isNotEmpty) 'alternate_titles': alternateTitles,
        'format': format.name,
        if (season != null) 'season': season!.name,
        if (seasonYear != null) 'season_year': seasonYear,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodeRuntimeMinutes != null)
          'episode_runtime_minutes': episodeRuntimeMinutes,
        'airing_status': airingStatus.name,
        if (startDate != null) 'start_date': startDate!.toIso8601String(),
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        if (studios.isNotEmpty) 'studios': studios,
        if (producers.isNotEmpty) 'producers': producers,
        if (licensors.isNotEmpty) 'licensors': licensors,
        'source_material': sourceMaterial.name,
        if (genres.isNotEmpty) 'genres': genres,
        if (themes.isNotEmpty) 'themes': themes,
        'country': country,
        'language': language,
        if (relations.isNotEmpty)
          'relations': relations.map((e) => e.toJson()).toList(),
        if (synopsis != null) 'synopsis': synopsis,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'anime',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.anime,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        releaseDate: startDate,
        releaseYear: startDate?.year ?? seasonYear,
      ),
      kindPayload: toJson(),
    );
  }
}

@immutable
final class AnimeEntry {
  const AnimeEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final AnimeCatalog catalog;
  final AnimeOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory AnimeEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? AnimeCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : AnimeCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.anime,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return AnimeEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.animeDetails,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
