import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MovieCatalog {
  const MovieCatalog({
    required this.identity,
    required this.title,
    this.originalTitle,
    this.sortTitle,
    this.synopsis,
    this.genres = const [],
    this.runtimeMinutes,
    this.audienceRating,
    this.ageRating,
    this.studio,
    this.productionCompanies = const [],
    this.country,
    this.originalLanguage,
    this.releaseDate,
    this.directors = const [],
    this.writers = const [],
    this.producers = const [],
    this.cast = const [],
    this.crew = const [],
    this.trailerUrls = const [],
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.releases = const [],
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? originalTitle;
  final String? sortTitle;
  final String? synopsis;
  final List<String> genres;
  final int? runtimeMinutes;
  final String? audienceRating;
  final String? ageRating;
  final String? studio;
  final List<String> productionCompanies;
  final String? country;
  final String? originalLanguage;
  final DateTime? releaseDate;
  final List<MoviePersonCredit> directors;
  final List<MoviePersonCredit> writers;
  final List<MoviePersonCredit> producers;
  final List<MoviePersonCredit> cast;
  final List<MoviePersonCredit> crew;
  final List<String> trailerUrls;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<MovieReleaseMetadata> releases;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.movie;
  String? get director => directors.firstOrNull?.name;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory MovieCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.movie,
    );

    final rawReleases = (json['releases'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(MovieReleaseMetadata.fromJson)
            .toList(growable: false) ??
        const <MovieReleaseMetadata>[];

    return MovieCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      originalTitle: json['original_title'] as String?,
      sortTitle: json['sort_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      runtimeMinutes: json['runtime_minutes'] as int?,
      audienceRating: json['audience_rating'] as String?,
      ageRating: json['age_rating'] as String?,
      studio: json['studio'] as String?,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      country: json['country'] as String?,
      originalLanguage: json['original_language'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      directors: (json['directors'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(MoviePersonCredit.fromJson)
              .toList() ??
          const [],
      writers: (json['writers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(MoviePersonCredit.fromJson)
              .toList() ??
          const [],
      producers: (json['producers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(MoviePersonCredit.fromJson)
              .toList() ??
          const [],
      cast: (json['cast'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(MoviePersonCredit.fromJson)
              .toList() ??
          const [],
      crew: (json['crew'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(MoviePersonCredit.fromJson)
              .toList() ??
          const [],
      trailerUrls: (json['trailer_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      releases: rawReleases,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'movie',
        'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (genres.isNotEmpty) 'genres': genres,
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (ageRating != null) 'age_rating': ageRating,
        if (studio != null) 'studio': studio,
        if (productionCompanies.isNotEmpty)
          'production_companies': productionCompanies,
        if (country != null) 'country': country,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (directors.isNotEmpty)
          'directors': directors.map((e) => e.toJson()).toList(),
        if (writers.isNotEmpty)
          'writers': writers.map((e) => e.toJson()).toList(),
        if (producers.isNotEmpty)
          'producers': producers.map((e) => e.toJson()).toList(),
        if (cast.isNotEmpty) 'cast': cast.map((e) => e.toJson()).toList(),
        if (crew.isNotEmpty) 'crew': crew.map((e) => e.toJson()).toList(),
        if (trailerUrls.isNotEmpty) 'trailer_urls': trailerUrls,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (releases.isNotEmpty)
          'releases': releases.map((e) => e.toJson()).toList(),
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'movie',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.movie,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        releaseDate: releaseDate,
        releaseYear: releaseDate?.year,
      ),
      payload: toJson(),
    );
  }
}

@immutable
final class MovieEntry {
  const MovieEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final MovieCatalog catalog;
  final MovieOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory MovieEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? MovieCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : MovieCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.movie,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return MovieEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.details as MovieOwnedDetails?,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
