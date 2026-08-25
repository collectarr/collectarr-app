import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BookCatalog {
  const BookCatalog({
    required this.identity,
    required this.title,
    this.subtitle,
    this.sortTitle,
    this.synopsis,
    this.authors = const [],
    this.genres = const [],
    this.subjects = const [],
    this.editors = const [],
    this.translators = const [],
    this.illustrators = const [],
    this.photographers = const [],
    this.coverArtists = const [],
    this.forewordAuthors = const [],
    this.ghostwriters = const [],
    this.originalTitle,
    this.originalSubtitle,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublisher,
    this.originalPublicationDate,
    this.country,
    this.language,
    this.creators = const [],
    this.publishing,
    this.links = const [],
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.editions = const [],
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? subtitle;
  final String? sortTitle;
  final String? synopsis;
  final List<String> authors;
  final List<String> genres;
  final List<String> subjects;
  final List<String> editors;
  final List<String> translators;
  final List<String> illustrators;
  final List<String> photographers;
  final List<String> coverArtists;
  final List<String> forewordAuthors;
  final List<String> ghostwriters;
  final String? originalTitle;
  final String? originalSubtitle;
  final String? originalCountry;
  final String? originalLanguage;
  final String? originalPublisher;
  final DateTime? originalPublicationDate;
  final String? country;
  final String? language;
  final List<Map<String, dynamic>> creators;
  final CatalogPublishingDetailsDto? publishing;
  final List<TrailerLink> links;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final List<BookEditionMetadata> editions;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.book;
  String? get author => authors.firstOrNull;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory BookCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.book,
    );

    final rawEditions = (json['editions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(BookEditionMetadata.fromJson)
            .toList(growable: false) ??
        const <BookEditionMetadata>[];

    final pubMap = json['publishing'] as Map<String, dynamic>?;
    final publishing = pubMap != null
        ? CatalogPublishingDetailsDto.fromJson(pubMap)
        : null;

    final rawLinks = <TrailerLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TrailerLink.fromJson) ??
          const <TrailerLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TrailerLink.fromJson) ??
          const <TrailerLink>[]),
    ];

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];

    return BookCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      subtitle: json['subtitle'] as String?,
      sortTitle: json['sort_title'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      editors: (json['editors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      translators: (json['translators'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      illustrators: (json['illustrators'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      photographers: (json['photographers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverArtists: (json['cover_artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      forewordAuthors: (json['foreword_authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ghostwriters: (json['ghostwriters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      originalTitle: json['original_title'] as String?,
      originalSubtitle: json['original_subtitle'] as String?,
      originalCountry: json['original_country'] as String?,
      originalLanguage: json['original_language'] as String?,
      originalPublisher: json['original_publisher'] as String?,
      originalPublicationDate: json['original_publication_date'] != null
          ? DateTime.tryParse(json['original_publication_date'] as String)
          : null,
      country: (json['country'] ?? json['original_country']) as String?,
      language: (json['language'] ?? json['original_language']) as String?,
      creators: rawCreators,
      publishing: publishing,
      links: rawLinks,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      coverImageData: json['cover_image_data'] as String?,
      editions: rawEditions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'book',
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (authors.isNotEmpty) 'authors': authors,
        if (genres.isNotEmpty) 'genres': genres,
        if (subjects.isNotEmpty) 'subjects': subjects,
        if (editors.isNotEmpty) 'editors': editors,
        if (translators.isNotEmpty) 'translators': translators,
        if (illustrators.isNotEmpty) 'illustrators': illustrators,
        if (photographers.isNotEmpty) 'photographers': photographers,
        if (coverArtists.isNotEmpty) 'cover_artists': coverArtists,
        if (forewordAuthors.isNotEmpty) 'foreword_authors': forewordAuthors,
        if (ghostwriters.isNotEmpty) 'ghostwriters': ghostwriters,
        if (originalTitle != null) 'original_title': originalTitle,
        if (originalSubtitle != null) 'original_subtitle': originalSubtitle,
        if (originalCountry != null) 'original_country': originalCountry,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (country != null) 'country': country,
        if (language != null) 'language': language,
        if (creators.isNotEmpty) 'creators': creators,
        if (publishing != null) 'publishing': publishing!.toJson(),
        if (links.isNotEmpty) ...{
          if (links.any((l) => l.isTrailerLink))
            'trailer_urls': links
                .where((l) => l.isTrailerLink)
                .map((e) => e.toJson())
                .toList(),
          if (links.any((l) => l.isExternalLink))
            'external_links': links
                .where((l) => l.isExternalLink)
                .map((e) => e.toJson())
                .toList(),
        },
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (coverImageData != null) 'cover_image_data': coverImageData,
        if (editions.isNotEmpty)
          'editions': editions.map((e) => e.toJson()).toList(),
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'book',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.book,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        sortKey: sortTitle,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        coverImageData: coverImageData,
        releaseDate: originalPublicationDate,
        releaseYear: originalPublicationDate?.year,
      ),
      payload: toJson(),
    );
  }
}

@immutable
final class BookEntry {
  const BookEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final BookCatalog catalog;
  final BookOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory BookEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? BookCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : BookCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.book,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return BookEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.bookDetails,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
