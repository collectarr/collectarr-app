import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class LibraryEntry {
  const LibraryEntry({
    required this.itemId,
    Object? catalogItem,
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
  }) : _catalogItem = catalogItem;

  final String itemId;
  final Object? _catalogItem;
  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;

  LibraryMetadataItem? get catalogItem {
    return switch (_catalogItem) {
      null => null,
      LibraryMetadataItem item => item,
      CatalogItem item => LibraryMetadataItem.fromCatalogItem(item),
      _ => null,
    };
  }

  bool get isOwned => ownedItem != null;
  bool get isTracked => trackingEntry != null;
  bool get isWishlisted => wishlistItem != null;
  bool get isMissingGrade => isOwned && ownedItem?.grade == null;
  bool get hasNotes =>
      (ownedItem?.personalNotes?.trim().isNotEmpty ?? false) ||
      (wishlistItem?.notes?.trim().isNotEmpty ?? false);

  MediaTracking get tracking =>
      trackingEntry?.mediaTracking ??
      ownedItem?.mediaTracking ??
      const MediaTracking(status: MediaTrackingStatus.none);

  DateTime get updatedAt {
    final ownedUpdated = ownedItem?.updatedAt;
    final trackingUpdated = trackingEntry?.updatedAt;
    final wishUpdated = wishlistItem?.updatedAt;
    DateTime? latest = ownedUpdated;
    if (trackingUpdated != null &&
        (latest == null || trackingUpdated.isAfter(latest))) {
      latest = trackingUpdated;
    }
    if (wishUpdated != null && (latest == null || wishUpdated.isAfter(latest))) {
      latest = wishUpdated;
    }
    return latest ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String get title {
    final item = catalogItem;
    if (item == null) {
      final length = itemId.length < 8 ? itemId.length : 8;
      return 'Catalog item ${itemId.substring(0, length)}';
    }
    if (item.itemNumber == null) {
      return item.title;
    }
    return '${item.title} #${item.itemNumber}';
  }

  String get subtitle {
    if (isOwned && isWishlisted) {
      return 'Owned and wishlisted';
    }
    if (isOwned) {
      return 'Owned';
    }
    if (isTracked) {
      return 'Tracked';
    }
    return 'Wishlist';
  }
}