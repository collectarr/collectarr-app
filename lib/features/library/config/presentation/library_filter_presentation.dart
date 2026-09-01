import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

class LibraryFilterOptionLabels {
  const LibraryFilterOptionLabels({
    this.ownershipAll = 'All items',
    this.ownershipOwned = 'Owned only',
    this.ownershipWishlist = 'Wishlist only',
    this.ownershipMissingGrade = 'Missing grade',
    this.ownershipForSale = 'For sale',
    this.ownershipOnOrder = 'On order',
    this.trackingAny = 'Any tracking status',
    this.trackingNotTracked = 'Not tracked',
    this.loanAny = 'Any loan status',
    this.loanOnLoan = 'Currently on loan',
    this.loanAvailable = 'Available locally',
    this.dateUpdated = 'Updated',
    this.datePurchased = 'Purchased',
    this.dateStarted = 'Started',
    this.dateFinished = 'Finished',
  });

  final String ownershipAll;
  final String ownershipOwned;
  final String ownershipWishlist;
  final String ownershipMissingGrade;
  final String ownershipForSale;
  final String ownershipOnOrder;
  final String trackingAny;
  final String trackingNotTracked;
  final String loanAny;
  final String loanOnLoan;
  final String loanAvailable;
  final String dateUpdated;
  final String datePurchased;
  final String dateStarted;
  final String dateFinished;
}

class LibraryFilterFieldDefinition {
  const LibraryFilterFieldDefinition(this.id, {this.label});

  final String id;
  final String? label;
}

const defaultLibraryFilterFieldDefinitions = [
  LibraryFilterFieldDefinition('series'),
  LibraryFilterFieldDefinition('location'),
  LibraryFilterFieldDefinition('tag'),
  LibraryFilterFieldDefinition('publisher'),
  LibraryFilterFieldDefinition('year'),
  LibraryFilterFieldDefinition('grade'),
  LibraryFilterFieldDefinition('condition'),
  LibraryFilterFieldDefinition('country'),
  LibraryFilterFieldDefinition('language'),
];

class LibraryMediaFilterLabels {
  const LibraryMediaFilterLabels({
    required this.series,
    required this.anySeries,
    required this.publisher,
    required this.anyPublisher,
    this.year = 'Year',
    this.anyYear = 'Any year',
  });

  final String series;
  final String anySeries;
  final String publisher;
  final String anyPublisher;
  final String year;
  final String anyYear;
}

class LibraryMediaGroupLabels {
  const LibraryMediaGroupLabels({
    required this.series,
    required this.seriesPlural,
    required this.unknownSeries,
    required this.publisher,
    required this.publisherPlural,
    required this.unknownPublisher,
    String? publisherMode,
    this.genre = 'Genre',
    this.genrePlural = 'Genres',
  }) : publisherMode = publisherMode ?? publisher;

  final String series;
  final String seriesPlural;
  final String unknownSeries;
  final String publisher;
  final String publisherPlural;
  final String unknownPublisher;
  final String publisherMode;
  final String genre;
  final String genrePlural;
}

class LibraryBucketLabelOverrides {
  const LibraryBucketLabelOverrides({
    this.storyArc = 'Story arc',
    this.character = 'Character',
    this.noGenre = 'No genre',
    this.unknownCountry = 'Unknown country',
    this.unknownLanguage = 'Unknown language',
    this.owned = 'Owned',
    this.wishlist = 'Wishlist',
    this.catalogOnly = 'Catalog only',
  });

  final String storyArc;
  final String character;
  final String noGenre;
  final String unknownCountry;
  final String unknownLanguage;
  final String owned;
  final String wishlist;
  final String catalogOnly;
}

class LibraryReferenceLabels {
  const LibraryReferenceLabels({
    this.itemScope = 'Media',
    this.editionScope = 'Edition',
    this.variantScope = 'Physical release',
    this.bundleScope = 'Bundle',
    this.bundleHierarchy = 'Bundle release',
    this.editionHierarchy = 'Edition',
    this.variantHierarchy = 'Physical',
  });

  final String itemScope;
  final String editionScope;
  final String variantScope;
  final String bundleScope;
  final String bundleHierarchy;
  final String editionHierarchy;
  final String variantHierarchy;

  String get ownedAsItem => 'Owned as ${itemScope.toLowerCase()}';
  String get ownedAsEdition => 'Owned as ${editionScope.toLowerCase()}';
  String get ownedAsVariant => 'Owned as ${variantScope.toLowerCase()}';
  String get ownedAsBundle => 'Owned as ${bundleScope.toLowerCase()}';
  String get wishlistedAsItem => 'Wishlisted as ${itemScope.toLowerCase()}';
  String get wishlistedAsEdition =>
      'Wishlisted as ${editionScope.toLowerCase()}';
  String get wishlistedAsVariant =>
      'Wishlisted as ${variantScope.toLowerCase()}';
  String get wishlistedAsBundle => 'Wishlisted as ${bundleScope.toLowerCase()}';
}

class LibraryStatusLabels {
  const LibraryStatusLabels({
    this.owned = 'Owned',
    this.tracked = 'Tracked',
    this.wishlist = 'Wishlist',
    this.localCatalog = 'Local catalog',
  });

  final String owned;
  final String tracked;
  final String wishlist;
  final String localCatalog;
}

class LibraryBucketingContext {
  const LibraryBucketingContext({
    required this.source,
    required this.item,
    required this.groupMode,
  });

  final ShelfEntry source;
  final LibraryProjectionRuntime item;
  final String groupMode;
}

typedef LibraryBucketLabelBuilder = String Function(
  LibraryBucketingContext context,
);
