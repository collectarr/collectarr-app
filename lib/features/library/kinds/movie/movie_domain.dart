import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_release.dart';

export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_release.dart';

// ---------------------------------------------------------------------------
// Transitional typedefs
// ---------------------------------------------------------------------------
typedef MovieWork = VideoCatalogItem;
typedef MovieRelease = VideoRelease;
typedef MovieReleaseMedia = VideoMediaRef;

// ---------------------------------------------------------------------------
// MoviePersonalOverlay
// ---------------------------------------------------------------------------

final class MoviePersonalOverlay {
  const MoviePersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.updatedAt,
    this.isOwnedOverride,
    this.isTrackedOverride,
    this.isWishlistedOverride,
  });

  factory MoviePersonalOverlay.fromShelfEntry(ShelfEntry source) {
    return MoviePersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      watchSessions: source.watchSessions,
      itemImages: source.itemImages,
      updatedAt: source.updatedAt,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final DateTime? updatedAt;
  final bool? isOwnedOverride;
  final bool? isTrackedOverride;
  final bool? isWishlistedOverride;

  bool get isOwned => isOwnedOverride ?? ownedItem != null;
  bool get isTracked => isTrackedOverride ?? trackingEntry != null;
  bool get isWishlisted => isWishlistedOverride ?? wishlistItem != null;
}

// ---------------------------------------------------------------------------
// Extension getters for VideoRelease required by movie workspace builder
// ---------------------------------------------------------------------------

extension VideoReleaseMovieExt on VideoRelease {
  CatalogEdition toCatalogEdition() {
    return CatalogEdition(
      id: id,
      title: title,
      publisher: publisher,
      distributor: distributor,
      upc: barcode,
      releaseDate: releaseDate,
      physicalFormat: formatLabel,
      physicalFormatLabel: formatLabel,
    );
  }

  String? get backCoverUrl => null;
  CatalogPublishingDetails? get publishingDetails => null;
  VideoCatalogDetails? get videoDetails => null;
  List<TrailerLink> get trailerUrls => const <TrailerLink>[];
  String? get country => null;
  String? get language => null;
}

// ---------------------------------------------------------------------------
// Extension getters for VideoCatalogItem required by movie workspace builder
// ---------------------------------------------------------------------------

extension VideoCatalogItemMovieExt on VideoCatalogItem {
  String get title => work.title;
  String? get originalTitle => work.originalTitle;
  String? get synopsis => work.synopsis;
  DateTime? get releaseDate => work.releaseDate;
  String? get originalLanguage => work.originalLanguage;
  String? get ageRating => technical.ageRating;
  String? get audienceRating => technical.audienceRating;
  String? get coverImageUrl =>
      releases.isEmpty ? null : releases.first.frontCoverUrl;
  String? get thumbnailImageUrl => coverImageUrl;
  bool get hasMissingCoreMetadata =>
      work.title.isEmpty || (work.synopsis == null && releases.isEmpty);
  List<TrailerLink> get trailerUrls => const <TrailerLink>[];
  String? get description => work.synopsis;
  List<Map<String, dynamic>>? get contributions => null;
  List<Map<String, dynamic>> get characterAppearances =>
      const <Map<String, dynamic>>[];
  CatalogSeriesDetails? get series => null;
  CatalogPublishingDetails? get publishingDetails => null;
  VideoCatalogDetails get videoDetails =>
      VideoCatalogDetails(runtimeMinutes: technical.runtimeMinutes);
}

// ---------------------------------------------------------------------------
// MovieRelease static factories (separate helper class)
// ---------------------------------------------------------------------------

abstract final class MovieReleaseFactory {
  static VideoRelease fromCatalogEdition(
    CatalogEdition edition, {
    required String workId,
  }) {
    final discs = edition.discs
        .map((disc) => VideoMediaRef(
              id: '${edition.id}:disc:${disc.discNumber}',
              title: disc.discName,
              formatLabel: disc.discFormat,
              discNumber: disc.discNumber,
            ))
        .toList();
    return VideoRelease(
      id: edition.id,
      title: edition.title,
      publisher: edition.publisher,
      distributor: edition.distributor,
      barcode: edition.upc ?? edition.isbn,
      releaseDate: edition.releaseDate,
      formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
      media: discs,
    );
  }
}
