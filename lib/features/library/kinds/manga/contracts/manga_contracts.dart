import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MangaCatalog {
  const MangaCatalog({
    required this.identity,
    required this.title,
    this.nativeTitle,
    this.romajiTitle,
    this.englishTitle,
    this.alternateTitles = const [],
    this.authors = const [],
    this.artists = const [],
    this.demographic = MangaDemographic.other,
    this.serializationPlatform,
    this.publicationStatus = MangaPublicationStatus.ongoing,
    this.originalPublisher,
    this.localizedPublisher,
    this.volumeNumber,
    this.totalVolumes,
    this.chapterCount,
    this.originalPublicationDate,
    this.localizedReleaseDate,
    this.isbn,
    this.editionFormat = MangaEditionFormat.tankobon,
    this.language = 'ja',
    this.country = 'JP',
    this.genres = const [],
    this.themes = const [],
    this.translator,
    this.readingDirection = MangaReadingDirection.rightToLeft,
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
  final List<String> authors;
  final List<String> artists;
  final MangaDemographic demographic;
  final String? serializationPlatform;
  final MangaPublicationStatus publicationStatus;
  final String? originalPublisher;
  final String? localizedPublisher;
  final int? volumeNumber;
  final int? totalVolumes;
  final int? chapterCount;
  final DateTime? originalPublicationDate;
  final DateTime? localizedReleaseDate;
  final String? isbn;
  final MangaEditionFormat editionFormat;
  final String language;
  final String country;
  final List<String> genres;
  final List<String> themes;
  final String? translator;
  final MangaReadingDirection readingDirection;
  final List<String> relations;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.manga;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory MangaCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.manga,
    );

    return MangaCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      nativeTitle: json['native_title'] as String?,
      romajiTitle: json['romaji_title'] as String?,
      englishTitle: json['english_title'] as String?,
      alternateTitles: (json['alternate_titles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      authors: (json['authors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      demographic: MangaDemographic.fromString(json['demographic'] as String?),
      serializationPlatform: json['serialization_platform'] as String?,
      publicationStatus: MangaPublicationStatus.fromString(
          json['publication_status'] as String?),
      originalPublisher: json['original_publisher'] as String?,
      localizedPublisher: json['localized_publisher'] as String?,
      volumeNumber: json['volume_number'] as int?,
      totalVolumes: json['total_volumes'] as int?,
      chapterCount: json['chapter_count'] as int?,
      originalPublicationDate: json['original_publication_date'] != null
          ? DateTime.tryParse(json['original_publication_date'] as String)
          : null,
      localizedReleaseDate: json['localized_release_date'] != null
          ? DateTime.tryParse(json['localized_release_date'] as String)
          : null,
      isbn: json['isbn'] as String?,
      editionFormat:
          MangaEditionFormat.fromString(json['edition_format'] as String?),
      language: (json['language'] as String?) ?? 'ja',
      country: (json['country'] as String?) ?? 'JP',
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      translator: json['translator'] as String?,
      readingDirection: MangaReadingDirection.fromString(
          json['reading_direction'] as String?),
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'manga',
        'title': title,
        if (nativeTitle != null) 'native_title': nativeTitle,
        if (romajiTitle != null) 'romaji_title': romajiTitle,
        if (englishTitle != null) 'english_title': englishTitle,
        if (alternateTitles.isNotEmpty) 'alternate_titles': alternateTitles,
        if (authors.isNotEmpty) 'authors': authors,
        if (artists.isNotEmpty) 'artists': artists,
        'demographic': demographic.name,
        if (serializationPlatform != null)
          'serialization_platform': serializationPlatform,
        'publication_status': publicationStatus.name,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (localizedPublisher != null)
          'localized_publisher': localizedPublisher,
        if (volumeNumber != null) 'volume_number': volumeNumber,
        if (totalVolumes != null) 'total_volumes': totalVolumes,
        if (chapterCount != null) 'chapter_count': chapterCount,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (localizedReleaseDate != null)
          'localized_release_date': localizedReleaseDate!.toIso8601String(),
        if (isbn != null) 'isbn': isbn,
        'edition_format': editionFormat.name,
        'language': language,
        'country': country,
        if (genres.isNotEmpty) 'genres': genres,
        if (themes.isNotEmpty) 'themes': themes,
        if (translator != null) 'translator': translator,
        'reading_direction': readingDirection.name,
        if (relations.isNotEmpty) 'relations': relations,
        if (synopsis != null) 'synopsis': synopsis,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'manga',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.manga,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        releaseDate: localizedReleaseDate ?? originalPublicationDate,
        releaseYear:
            (localizedReleaseDate ?? originalPublicationDate)?.year,
      ),
      kindPayload: toJson(),
    );
  }
}

@immutable
final class MangaEntry {
  const MangaEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final MangaCatalog catalog;
  final MangaOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory MangaEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? MangaCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : MangaCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.manga,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return MangaEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.mangaDetails,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
