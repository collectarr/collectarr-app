import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';

export 'package:collectarr_app/core/models/tracking_summary.dart';

/// Structural entry used by mixed/global Shelf hosts.
///
/// This model deliberately contains projections and references only. A
/// caller that needs kind semantics must use the kind-specific workspace
/// source instead of widening this mixed entry with another common aggregate.
class LibraryEntry {
  const LibraryEntry({
    required this.itemId,
    this.catalogSummary,
    this.ownedSummary,
    this.trackingSummary,
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.fallbackOwnerLabel,
  });

  final String itemId;
  final CatalogDisplaySummary? catalogSummary;
  final OwnedItemSummary? ownedSummary;
  final TrackingSummary? trackingSummary;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final String? fallbackOwnerLabel;

  CatalogEntityRef? get catalogRef =>
      catalogSummary?.ref ??
      ownedSummary?.catalogRef ??
      wishlistItem?.catalogRef;

  bool get isOwned => ownedSummary != null;
  bool get isTracked => trackingSummary != null;
  bool get isWishlisted => wishlistItem != null;
  bool get hasNotes =>
      (ownedSummary?.hasNotes ?? false) ||
      (wishlistItem?.notes?.trim().isNotEmpty ?? false);

  MediaTrackingStatus get trackingStatus =>
      trackingSummary?.status ?? MediaTrackingStatus.none;
  int? get trackingRating => trackingSummary?.rating;
  DateTime? get trackingStartedAt => trackingSummary?.startedAt;
  DateTime? get trackingCompletedAt => trackingSummary?.completedAt;
  String? get trackingNotes => trackingSummary?.notes;
  String get trackingStatusLabel => trackingStatus.label;

  DateTime get updatedAt {
    final values = <DateTime>[
      if (ownedSummary?.updatedAt case final value?) value,
      if (trackingSummary?.updatedAt case final value?) value,
      if (wishlistItem?.updatedAt case final value?) value,
    ];
    if (values.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  DateTime? get addedAt => ownedSummary?.createdAt ?? wishlistItem?.createdAt;

  String get title {
    final value = catalogSummary?.title.trim();
    if (value != null && value.isNotEmpty) return value;
    final ownedTitle = ownedSummary?.title.trim();
    if (ownedTitle != null && ownedTitle.isNotEmpty) return ownedTitle;
    final length = itemId.length < 8 ? itemId.length : 8;
    return 'Catalog item ${itemId.substring(0, length)}';
  }

  String get subtitle {
    if (isOwned && isWishlisted) return 'Owned and wishlisted';
    if (isOwned) return 'Owned';
    if (isTracked) return 'Tracked';
    return 'Wishlist';
  }

  String? get ownerLabel => ownedSummary?.ownerLabel ?? fallbackOwnerLabel;

  int get quantity => ownedSummary?.quantity ?? 0;
}

/// Full source used after a kind has been selected by the Library workspace.
///
/// This is deliberately not a subtype of [LibraryEntry]. The mixed Shelf
/// projection and the post-dispatch workspace source have different
/// ownership rules; making one inherit from the other recreates the generic
/// catalog/Owned union.
///
/// Tracking is intentionally represented only by [TrackingSummary]. A full
/// [TrackingEntry] is a persistence aggregate and must not be carried through
/// every workspace row.
class LibraryWorkspaceSource {
  const LibraryWorkspaceSource({
    required this.itemId,
    this.catalogSummary,
    this.ownedSummary,
    this.trackingSummary,
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.fallbackOwnerLabel,
  });

  final String itemId;
  final CatalogDisplaySummary? catalogSummary;
  final OwnedItemSummary? ownedSummary;
  final TrackingSummary? trackingSummary;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final String? fallbackOwnerLabel;

  CatalogEntityRef? get catalogRef =>
      catalogSummary?.ref ??
      ownedSummary?.catalogRef ??
      wishlistItem?.catalogRef;
  CatalogMediaKind get mediaKind =>
      catalogSummary?.kind ?? CatalogMediaKind.unknown;
  OwnedItemRef? get ownedRef => ownedSummary?.ref;

  bool get isOwned => ownedSummary != null;
  bool get isTracked => trackingSummary != null;
  bool get isWishlisted => wishlistItem != null;

  String get subtitle {
    if (isOwned && isWishlisted) return 'Owned and wishlisted';
    if (isOwned) return 'Owned';
    if (isTracked) return 'Tracked';
    return 'Wishlist';
  }

  bool get hasNotes =>
      (ownedSummary?.hasNotes ?? false) ||
      (wishlistItem?.notes?.trim().isNotEmpty ?? false);

  DateTime get updatedAt {
    final values = <DateTime>[
      if (ownedSummary?.updatedAt case final value?) value,
      if (trackingSummary?.updatedAt case final value?) value,
      if (wishlistItem?.updatedAt case final value?) value,
    ];
    if (values.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  DateTime? get addedAt => ownedSummary?.createdAt ?? wishlistItem?.createdAt;

  String get title {
    final value = catalogSummary?.title.trim();
    if (value != null && value.isNotEmpty) return value;
    final length = itemId.length < 8 ? itemId.length : 8;
    return 'Catalog item ${itemId.substring(0, length)}';
  }

  MediaTrackingStatus get trackingStatus =>
      trackingSummary?.status ?? MediaTrackingStatus.none;
  int? get trackingRating => trackingSummary?.rating;
  DateTime? get trackingStartedAt => trackingSummary?.startedAt;
  DateTime? get trackingCompletedAt => trackingSummary?.completedAt;
  String? get trackingNotes => trackingSummary?.notes;
  String get trackingStatusLabel => trackingStatus.label;

  String? get ownerLabel => ownedSummary?.ownerLabel ?? fallbackOwnerLabel;

  int get quantity => ownedSummary?.quantity ?? 0;
}
