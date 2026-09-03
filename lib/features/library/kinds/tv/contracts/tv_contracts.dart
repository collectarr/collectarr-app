import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class TvCatalog {
  const TvCatalog({
    required this.identity,
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.firstAirDate,
    this.lastAirDate,
    this.status,
    this.network,
    this.streamingService,
    this.productionCompanies = const [],
    this.country = 'US',
    this.originalLanguage = 'en',
    this.genres = const [],
    this.contentRating,
    this.seasonCount,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    this.cast = const [],
    this.crew = const [],
    this.seasons = const [],
    this.releases = const [],
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? originalTitle;
  final String? synopsis;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final String? status;
  final String? network;
  final String? streamingService;
  final List<String> productionCompanies;
  final String country;
  final String originalLanguage;
  final List<String> genres;
  final String? contentRating;
  final int? seasonCount;
  final int? episodeCount;
  final int? episodeRuntimeMinutes;
  final List<TvPersonCredit> cast;
  final List<TvPersonCredit> crew;
  final List<TvSeasonMetadata> seasons;
  final List<TvPhysicalReleaseMetadata> releases;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.tv;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory TvCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.tv,
    );

    final rawSeasons = (json['seasons'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TvSeasonMetadata.fromJson)
            .toList(growable: false) ??
        const <TvSeasonMetadata>[];

    final rawReleases = (json['releases'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TvPhysicalReleaseMetadata.fromJson)
            .toList(growable: false) ??
        const <TvPhysicalReleaseMetadata>[];

    return TvCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      synopsis: (json['synopsis'] ?? json['overview']) as String?,
      firstAirDate: json['first_air_date'] != null
          ? DateTime.tryParse(json['first_air_date'] as String)
          : null,
      lastAirDate: json['last_air_date'] != null
          ? DateTime.tryParse(json['last_air_date'] as String)
          : null,
      status: json['status'] as String?,
      network: json['network'] as String?,
      streamingService: json['streaming_service'] as String?,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: (json['country'] as String?) ?? 'US',
      originalLanguage: (json['original_language'] as String?) ?? 'en',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      contentRating: (json['content_rating'] ?? json['age_rating']) as String?,
      seasonCount: json['season_count'] as int?,
      episodeCount: json['episode_count'] as int?,
      episodeRuntimeMinutes: json['episode_runtime_minutes'] as int?,
      cast: (json['cast'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TvPersonCredit.fromJson)
              .toList() ??
          const [],
      crew: (json['crew'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TvPersonCredit.fromJson)
              .toList() ??
          const [],
      seasons: rawSeasons,
      releases: rawReleases,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'tv',
        'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (firstAirDate != null)
          'first_air_date': firstAirDate!.toIso8601String(),
        if (lastAirDate != null)
          'last_air_date': lastAirDate!.toIso8601String(),
        if (status != null) 'status': status,
        if (network != null) 'network': network,
        if (streamingService != null) 'streaming_service': streamingService,
        if (productionCompanies.isNotEmpty)
          'production_companies': productionCompanies,
        'country': country,
        'original_language': originalLanguage,
        if (genres.isNotEmpty) 'genres': genres,
        if (contentRating != null) 'content_rating': contentRating,
        if (seasonCount != null) 'season_count': seasonCount,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (episodeRuntimeMinutes != null)
          'episode_runtime_minutes': episodeRuntimeMinutes,
        if (cast.isNotEmpty) 'cast': cast.map((e) => e.toJson()).toList(),
        if (crew.isNotEmpty) 'crew': crew.map((e) => e.toJson()).toList(),
        if (seasons.isNotEmpty)
          'seasons': seasons.map((e) => e.toJson()).toList(),
        if (releases.isNotEmpty)
          'releases': releases.map((e) => e.toJson()).toList(),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'tv',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.tv,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        releaseDate: firstAirDate,
        releaseYear: firstAirDate?.year,
      ),
      payload: toJson(),
    );
  }
}

@immutable
final class TvEntry {
  const TvEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final TvCatalog catalog;
  final TvOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory TvEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? TvCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : TvCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.tv,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return TvEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.details as TvOwnedDetails?,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
