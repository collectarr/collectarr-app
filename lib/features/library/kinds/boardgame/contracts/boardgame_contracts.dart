import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BoardGameCatalog {
  const BoardGameCatalog({
    required this.identity,
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.recommendedPlayers,
    this.bestPlayers,
    this.minPlaytimeMinutes,
    this.maxPlaytimeMinutes,
    this.minimumAge,
    this.complexityWeight,
    this.designers = const [],
    this.artists = const [],
    this.publishers = const [],
    this.mechanics = const [],
    this.categories = const [],
    this.families = const [],
    this.themes = const [],
    this.expansions = const [],
    this.expansionFor,
    this.languages = const [],
    this.bggRating,
    this.bggRatingCount,
    this.bggRank,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? originalTitle;
  final String? synopsis;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final String? recommendedPlayers;
  final String? bestPlayers;
  final int? minPlaytimeMinutes;
  final int? maxPlaytimeMinutes;
  final int? minimumAge;
  final double? complexityWeight;
  final List<String> designers;
  final List<String> artists;
  final List<String> publishers;
  final List<String> mechanics;
  final List<String> categories;
  final List<String> families;
  final List<String> themes;
  final List<String> expansions;
  final String? expansionFor;
  final List<String> languages;
  final double? bggRating;
  final int? bggRatingCount;
  final int? bggRank;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.boardgame;
  String? get designer => designers.firstOrNull;
  String? get publisher => publishers.firstOrNull;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory BoardGameCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.boardgame,
    );

    return BoardGameCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      yearPublished:
          json['year_published'] as int? ?? json['release_year'] as int?,
      minPlayers: json['min_players'] as int?,
      maxPlayers: json['max_players'] as int?,
      recommendedPlayers: json['recommended_players'] as String?,
      bestPlayers: json['best_players'] as String?,
      minPlaytimeMinutes: json['min_playtime_minutes'] as int?,
      maxPlaytimeMinutes: json['max_playtime_minutes'] as int?,
      minimumAge: json['minimum_age'] as int? ?? json['min_age'] as int?,
      complexityWeight: (json['complexity_weight'] as num?)?.toDouble() ??
          (json['weight'] as num?)?.toDouble(),
      designers: (json['designers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishers: (json['publishers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      mechanics: (json['mechanics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      families: (json['families'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      expansions: (json['expansions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      expansionFor: json['expansion_for'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      bggRating: (json['bgg_rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble(),
      bggRatingCount: json['bgg_rating_count'] as int? ??
          json['rating_count'] as int? ??
          json['users_rated'] as int?,
      bggRank: json['bgg_rank'] as int? ?? json['rank'] as int?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'boardgame',
        'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (yearPublished != null) 'year_published': yearPublished,
        if (minPlayers != null) 'min_players': minPlayers,
        if (maxPlayers != null) 'max_players': maxPlayers,
        if (recommendedPlayers != null)
          'recommended_players': recommendedPlayers,
        if (bestPlayers != null) 'best_players': bestPlayers,
        if (minPlaytimeMinutes != null)
          'min_playtime_minutes': minPlaytimeMinutes,
        if (maxPlaytimeMinutes != null)
          'max_playtime_minutes': maxPlaytimeMinutes,
        if (minimumAge != null) 'minimum_age': minimumAge,
        if (complexityWeight != null) 'complexity_weight': complexityWeight,
        if (designers.isNotEmpty) 'designers': designers,
        if (artists.isNotEmpty) 'artists': artists,
        if (publishers.isNotEmpty) 'publishers': publishers,
        if (mechanics.isNotEmpty) 'mechanics': mechanics,
        if (categories.isNotEmpty) 'categories': categories,
        if (families.isNotEmpty) 'families': families,
        if (themes.isNotEmpty) 'themes': themes,
        if (expansions.isNotEmpty) 'expansions': expansions,
        if (expansionFor != null) 'expansion_for': expansionFor,
        if (languages.isNotEmpty) 'languages': languages,
        if (bggRating != null) 'bgg_rating': bggRating,
        if (bggRatingCount != null) 'bgg_rating_count': bggRatingCount,
        if (bggRank != null) 'bgg_rank': bggRank,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'boardgame',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.boardgame,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        releaseYear: yearPublished,
      ),
      payload: toJson(),
    );
  }
}

@immutable
final class BoardGameEntry {
  const BoardGameEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final BoardGameCatalog catalog;
  final BoardGameOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory BoardGameEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? BoardGameCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : BoardGameCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.boardgame,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return BoardGameEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.boardgameDetails,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
