import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/comic/contracts/comic_contracts.dart';
export 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_hierarchy_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_media.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_remote_source.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
export 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
export 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
export 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';

typedef ComicWork = ComicCatalogItem;
typedef ComicIssue = ComicCatalogItem;

final class ComicPersonalOverlay {
  const ComicPersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.lastBagBoardDate,
    this.signedBy,
    this.updatedAt,
  });

  factory ComicPersonalOverlay.fromShelf(ShelfEntry source) {
    final ownedItem = source.ownedItem == null
        ? null
        : ComicOwnedItemLegacyAdapter.fromLegacy(source.ownedItem!);
    return ComicPersonalOverlay(
      ownedItem: ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      lastBagBoardDate: ownedItem?.details.lastBagBoardDate,
      signedBy: ownedItem?.details.signedBy,
      updatedAt: source.updatedAt,
    );
  }

  final ComicOwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? lastBagBoardDate;
  final String? signedBy;
  final DateTime? updatedAt;

  ComicOwnedDetails? get _comicDetails => ownedItem?.details;

  bool get isSlabbed => _comicDetails?.rawOrSlabbed == 'Slabbed';
  bool get keyComic => _comicDetails?.keyComic ?? false;
  String? get gradingCompany => _comicDetails?.gradingCompany;
}
