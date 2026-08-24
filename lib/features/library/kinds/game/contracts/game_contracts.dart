import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class GameCatalog {
  const GameCatalog({
    required this.identity,
    required this.title,
    this.platform,
    this.releaseRegion,
    this.edition,
    this.developers = const [],
    this.publishers = const [],
    this.franchise,
    this.series,
    this.genres = const [],
    this.ageRating,
    this.languages = const [],
    this.country = 'US',
    this.synopsis,
    this.releaseDate,
    this.barcode,
    this.priceChartingId,
    this.valuations,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? platform;
  final String? releaseRegion;
  final String? edition;
  final List<String> developers;
  final List<String> publishers;
  final String? franchise;
  final String? series;
  final List<String> genres;
  final String? ageRating;
  final List<String> languages;
  final String country;
  final String? synopsis;
  final DateTime? releaseDate;
  final String? barcode;
  final String? priceChartingId;
  final GameValuationSet? valuations;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.game;
  String? get publisher => publishers.firstOrNull;
  String? get developer => developers.firstOrNull;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory GameCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.game,
    );

    return GameCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      platform: json['platform'] as String?,
      releaseRegion: json['release_region'] as String?,
      edition: json['edition'] as String?,
      developers: (json['developers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishers: (json['publishers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      franchise: json['franchise'] as String?,
      series: json['series'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ageRating: json['age_rating'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: (json['country'] as String?) ?? 'US',
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      barcode: json['barcode'] as String?,
      priceChartingId: json['price_charting_id'] as String?,
      valuations: json['valuations'] != null
          ? GameValuationSet.fromJson(
              json['valuations'] as Map<String, dynamic>)
          : null,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'game',
        'title': title,
        if (platform != null) 'platform': platform,
        if (releaseRegion != null) 'release_region': releaseRegion,
        if (edition != null) 'edition': edition,
        if (developers.isNotEmpty) 'developers': developers,
        if (publishers.isNotEmpty) 'publishers': publishers,
        if (franchise != null) 'franchise': franchise,
        if (series != null) 'series': series,
        if (genres.isNotEmpty) 'genres': genres,
        if (ageRating != null) 'age_rating': ageRating,
        if (languages.isNotEmpty) 'languages': languages,
        'country': country,
        if (synopsis != null) 'synopsis': synopsis,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (barcode != null) 'barcode': barcode,
        if (priceChartingId != null) 'price_charting_id': priceChartingId,
        if (valuations != null) 'valuations': valuations!.toJson(),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'game',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.game,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        releaseDate: releaseDate,
        releaseYear: releaseDate?.year,
      ),
      kindPayload: toJson(),
    );
  }
}

@immutable
final class GameEntry {
  const GameEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final GameCatalog catalog;
  final GameOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory GameEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? GameCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : GameCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.game,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return GameEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.gameDetails,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
