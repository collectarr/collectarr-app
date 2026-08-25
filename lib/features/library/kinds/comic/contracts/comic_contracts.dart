import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicLink {
  const ComicLink({
    required this.url,
    this.title,
    this.description,
    this.source,
    this.isAutomatic = true,
    this.kind = 'trailer',
  });

  final String url;
  final String? title;
  final String? description;
  final String? source;
  final bool isAutomatic;
  final String kind;

  bool get isExternalLink => kind == 'external' || kind == 'link';
  bool get isTrailerLink => !isExternalLink;

  factory ComicLink.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? json['type'])?.toString().toLowerCase();
    final source = json['source'] as String?;
    final inferredKind = rawKind ??
        ((source?.toLowerCase().contains('external') ?? false)
            ? 'external'
            : 'trailer');
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    return ComicLink(
      url: json['url'] as String,
      title: title ?? description,
      description: description ?? title,
      source: source,
      isAutomatic: json['is_automatic'] as bool? ?? true,
      kind: inferredKind,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (source != null) 'source': source,
        'is_automatic': isAutomatic,
        'kind': kind,
      };
}

@immutable
final class ComicCatalog {
  const ComicCatalog({
    required this.identity,
    required this.title,
    this.displayTitle,
    this.sortKey,
    this.issueNumber,
    this.series,
    this.publisher,
    this.imprint,
    this.releaseDate,
    this.coverDate,
    this.releaseYear,
    this.pageCount,
    this.country = 'US',
    this.language = 'en',
    this.ageRating,
    this.crossover,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.barcode,
    this.variant,
    this.variantDescription,
    this.genres = const [],
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.keyEvents = const [],
    this.isKeyComic = false,
    this.keyReason,
    this.publishing,
    this.links = const [],
    this.releases = const [],
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? displayTitle;
  final String? sortKey;
  final String? issueNumber;
  final CatalogSeriesDetailsDto? series;
  final String? publisher;
  final String? imprint;
  final DateTime? releaseDate;
  final DateTime? coverDate;
  final int? releaseYear;
  final int? pageCount;
  final String country;
  final String language;
  final String? ageRating;
  final String? crossover;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final String? barcode;
  final String? variant;
  final String? variantDescription;
  final List<String> genres;
  final List<Map<String, dynamic>> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<ComicKeyEvent> keyEvents;
  final bool isKeyComic;
  final String? keyReason;
  final CatalogPublishingDetailsDto? publishing;
  final List<ComicLink> links;
  final List<ComicRelease> releases;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.comic;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;
  String? get seriesTitle => series?.seriesTitle;

  factory ComicCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.comic,
    );

    final rawLinks = <ComicLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicLink.fromJson) ??
          const <ComicLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicLink.fromJson) ??
          const <ComicLink>[]),
    ];

    final seriesMap = json['series'] as Map<String, dynamic>?;
    final series = seriesMap != null
        ? CatalogSeriesDetailsDto.fromJson(seriesMap)
        : CatalogSeriesDetailsDto.fromJson(json);

    final pubMap = json['publishing'] as Map<String, dynamic>?;
    final publishing = pubMap != null
        ? CatalogPublishingDetailsDto.fromJson(pubMap)
        : CatalogPublishingDetailsDto.fromJson(json);

    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];

    final rawReleases = (json['editions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) =>
                ComicRelease.fromEditionDto(CatalogEditionDto.fromJson(e)))
            .toList(growable: false) ??
        const <ComicRelease>[];

    return ComicCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      displayTitle: json['display_title'] as String?,
      sortKey: json['sort_key'] as String?,
      issueNumber: (json['issue_number'] ?? json['item_number'])?.toString(),
      series: series.hasData ? series : null,
      publisher: (json['publisher'] ?? publishing.originalPublisher) as String?,
      imprint: (json['imprint'] ?? publishing.imprint) as String?,
      releaseDate: parseDate(json['release_date']),
      coverDate: parseDate(json['cover_date']),
      releaseYear: json['release_year'] as int?,
      pageCount: (json['page_count'] ?? publishing.pageCount) as int?,
      country: (json['country'] ?? 'US') as String,
      language: (json['language'] ?? 'en') as String,
      ageRating: json['age_rating'] as String?,
      crossover: json['crossover'] as String?,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      coverImageData: json['cover_image_data'] as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant'] as String?,
      variantDescription: json['variant_description'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      creators: rawCreators,
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      storyArcs: (json['story_arcs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      keyEvents: (json['key_events'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicKeyEvent.fromJson)
              .toList() ??
          const [],
      isKeyComic: json['is_key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      publishing: publishing.hasData ? publishing : null,
      links: rawLinks,
      releases: rawReleases,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'comic',
        'title': title,
        if (displayTitle != null) 'display_title': displayTitle,
        if (sortKey != null) 'sort_key': sortKey,
        if (issueNumber != null) 'issue_number': issueNumber,
        if (series != null) 'series': series!.toJson(),
        if (publisher != null) 'publisher': publisher,
        if (imprint != null) 'imprint': imprint,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (coverDate != null) 'cover_date': coverDate!.toIso8601String(),
        if (releaseYear != null) 'release_year': releaseYear,
        if (pageCount != null) 'page_count': pageCount,
        'country': country,
        'language': language,
        if (ageRating != null) 'age_rating': ageRating,
        if (crossover != null) 'crossover': crossover,
        if (synopsis != null) 'synopsis': synopsis,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (coverImageData != null) 'cover_image_data': coverImageData,
        if (barcode != null) 'barcode': barcode,
        if (variant != null) 'variant': variant,
        if (variantDescription != null)
          'variant_description': variantDescription,
        if (genres.isNotEmpty) 'genres': genres,
        if (creators.isNotEmpty) 'creators': creators,
        if (characters.isNotEmpty) 'characters': characters,
        if (storyArcs.isNotEmpty) 'story_arcs': storyArcs,
        if (keyEvents.isNotEmpty)
          'key_events': keyEvents.map((e) => e.toJson()).toList(),
        if (isKeyComic) 'is_key_comic': true,
        if (keyReason != null) 'key_reason': keyReason,
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
        if (releases.isNotEmpty)
          'editions': releases.map((e) => e.toEditionDto().toJson()).toList(),
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'comic',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.comic,
      common: CatalogCommonDto(
        title: title,
        displayTitle: displayTitle,
        sortKey: sortKey,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        coverImageData: coverImageData,
        releaseDate: releaseDate,
        releaseYear: releaseYear ?? coverDate?.year,
        trailerUrls: links
            .map((l) => TrailerLinkDto(
                  url: l.url,
                  title: l.title,
                  description: l.description,
                  source: l.source,
                  isAutomatic: l.isAutomatic,
                  kind: l.kind,
                ))
            .toList(),
      ),
      kindPayload: toJson(),
    );
  }
}

@immutable
final class ComicEntry {
  const ComicEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final ComicCatalog catalog;
  final ComicOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory ComicEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? ComicCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : ComicCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.comic,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return ComicEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.comicDetails,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
