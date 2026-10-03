import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_library_entry_projection.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';

export 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
export 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
export 'package:collectarr_app/features/library/kinds/tv/domain/tv_hierarchy_mapper.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_tables.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_mapper.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
export 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
export 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
export 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
export 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
export 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/add/tv_release_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
export 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_schema.dart';
export 'package:collectarr_app/features/library/kinds/tv/edit/tv_entry_edit_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/edit/tv_entry_edit_schema.dart';
export 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_profile.dart';
export 'package:collectarr_app/features/library/kinds/tv/provider/tv_seasons_provider.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_mapper.dart';

// ---------------------------------------------------------------------------
// TvPersonalOverlay
// ---------------------------------------------------------------------------
final class TvPersonalOverlay {
  const TvPersonalOverlay({
    this.libraryEntry,
    this.trackingSummary,
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.updatedAt,
    this.isEntryOverride,
    this.isTrackedOverride,
    this.isWishlistedOverride,
  });

  factory TvPersonalOverlay.fromShelf(LibraryWorkspaceSource source) {
    return TvPersonalOverlay(
      libraryEntry: TvLibraryEntryProjection.fromDispatch(
        source.libraryEntryDispatch,
      ),
      trackingSummary: source.trackingSummary,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      watchSessions: source.watchSessions,
      itemImages: source.itemImages,
      updatedAt: source.updatedAt,
    );
  }

  final TvLibraryEntry? libraryEntry;
  final TrackingSummary? trackingSummary;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final DateTime? updatedAt;
  final bool? isEntryOverride;
  final bool? isTrackedOverride;
  final bool? isWishlistedOverride;

  bool get isEntry => isEntryOverride ?? libraryEntry != null;
  bool get isTracked => isTrackedOverride ?? trackingSummary != null;
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
