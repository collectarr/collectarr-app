import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';

export 'package:collectarr_app/features/library/kinds/book/contracts/book_contracts.dart';
export 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
export 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
export 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';
export 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';

typedef BookWork = BookCatalogItem;
typedef BookEdition = BookRelease;

final class BookPersonalOverlay {
  const BookPersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
  });

  factory BookPersonalOverlay.fromShelf(ShelfEntry source) {
    return BookPersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;
}
