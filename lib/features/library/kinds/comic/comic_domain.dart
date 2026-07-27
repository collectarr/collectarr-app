import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';

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
    final comicDetails = source.ownedItem?.typedDetails is ComicOwnedDetails
        ? source.ownedItem!.typedDetails as ComicOwnedDetails
        : null;
    return ComicPersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      lastBagBoardDate: comicDetails?.lastBagBoardDate,
      signedBy: comicDetails?.signedBy,
      updatedAt: source.updatedAt,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? lastBagBoardDate;
  final String? signedBy;
  final DateTime? updatedAt;

  ComicOwnedDetails? get _comicDetails =>
      ownedItem?.typedDetails is ComicOwnedDetails
          ? ownedItem!.typedDetails as ComicOwnedDetails
          : null;

  bool get isSlabbed => _comicDetails?.rawOrSlabbed == 'Slabbed';
  bool get keyComic => _comicDetails?.keyComic ?? false;
  String? get gradingCompany => _comicDetails?.gradingCompany;
  ComicWorkspaceDetails? toWorkspaceDetails() {
    final details = _comicDetails;
    if (details == null) return null;
    return ComicWorkspaceDetails(
      rawOrSlabbed: details.rawOrSlabbed,
      gradingCompany: details.gradingCompany,
      labelType: details.labelType,
      certificationNumber: details.certificationNumber,
      keyComic: details.keyComic ?? false,
      keyReason: details.keyReason,
    );
  }
}
