import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

export 'package:collectarr_app/features/library/kinds/tv/contracts/tv_contracts.dart';
export 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
export 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_remote_source.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_tables.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_mapper.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
export 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
export 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
export 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_release.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';

// ---------------------------------------------------------------------------
// Transitional typedefs
// ---------------------------------------------------------------------------
typedef TvWork = VideoCatalogItem;

// ---------------------------------------------------------------------------
// TvPersonalOverlay
// ---------------------------------------------------------------------------
final class TvPersonalOverlay {
  const TvPersonalOverlay({
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

  factory TvPersonalOverlay.fromShelf(ShelfEntry source) {
    return TvPersonalOverlay(
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
// TvWorkspaceNode
// ---------------------------------------------------------------------------
enum TvWorkspaceNodeType { series, season, episode }

class TvWorkspaceNode {
  const TvWorkspaceNode({
    required this.id,
    required this.title,
    required this.nodeType,
  });

  final String id;
  final String title;
  final TvWorkspaceNodeType nodeType;
}

// ---------------------------------------------------------------------------
// Extension for VideoCatalogMapper used in tv workspace builder
// ---------------------------------------------------------------------------
extension TvVideoCatalogMapperExt on VideoCatalogMapper {
  static VideoCatalogItem fromTvMetadataItem(LibraryMetadataItem item) {
    final metadata = item.kindMetadata;
    if (metadata is! TvSeriesMetadata) {
      throw ArgumentError.value(
        metadata,
        'item.kindMetadata',
        'Expected TvSeriesMetadata',
      );
    }
    return VideoCatalogItem(
      id: item.id,
      work: VideoWorkMetadata(
        title: metadata.title,
        originalTitle: metadata.originalTitle,
        synopsis: metadata.synopsis,
        releaseDate: metadata.firstAirDate,
        originalLanguage: metadata.originalLanguage,
        genres: metadata.genres,
        series: metadata.series,
      ),
      technical: VideoTechnicalMetadata(
        runtimeMinutes: metadata.episodeRuntimeMinutes,
        ageRating: metadata.contentRating,
        audienceRating: metadata.contentRating,
      ),
      releases: [
        for (final release in metadata.releases)
          VideoRelease(
            id: release.id,
            title: release.title,
            publisher: metadata.publisher,
            barcode: release.barcode,
            releaseDate: release.releaseDate,
            formatLabel: release.packaging,
            media: [
              for (var disc = 1; disc <= (release.discCount ?? 0); disc++)
                VideoMediaRef(
                  id: '${release.id}:disc:$disc',
                  title: 'Disc $disc',
                  discNumber: disc,
                ),
            ],
          ),
      ],
      trailerUrls: metadata.links,
    );
  }
}
