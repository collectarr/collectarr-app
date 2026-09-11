import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

/// Concrete workspace source used after kind dispatch.
///
/// Mixed/global Shelf consumers use [CatalogDisplaySummary],
/// [OwnedItemSummary] and refs. This source additionally carries the opaque
/// selected catalog transport needed by the owning kind's workspace projector.
/// It is the concrete workspace source used by both mixed Shelf hosts and
/// kind-dispatched Library pages.
final class LibraryWorkspaceSource {
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
    this.catalogSearchTokens = const <String>[],
    this.catalogTransport,
    this.typedOwnedItem,
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

  /// Opaque catalog transport kept only for typed kind workspace code.
  final CatalogSearchCandidate? catalogTransport;

  /// Concrete kind-owned aggregate available after dispatch. Mixed/global
  /// callers must use [ownedSummary] instead.
  final Object? typedOwnedItem;

  /// Structural search tokens captured at the catalog boundary. Generic
  /// search may index these values but never inspects the transport payload.
  final List<String> catalogSearchTokens;

  CatalogEntityRef? get catalogRef =>
      catalogSummary?.ref ??
      ownedSummary?.catalogRef ??
      wishlistItem?.catalogRef ??
      catalogTransport?.catalogRef;

  CatalogMediaKind get mediaKind =>
      catalogSummary?.kind ??
      catalogTransport?.mediaKind ??
      CatalogMediaKind.unknown;

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
    final snapshotTitle = catalogTransport?.resolvedDisplayTitle.trim();
    if (snapshotTitle != null && snapshotTitle.isNotEmpty) {
      return snapshotTitle;
    }
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

  int? get pricePaidCents => ownedSummary?.pricePaidCents;
  int? get sellPriceCents => ownedSummary?.sellPriceCents;
  int? get marketValueCents => ownedSummary?.marketValueCents;
  String? get soldTo => ownedSummary?.soldTo;
  String? get currency => ownedSummary?.currency;
  String? get purchaseStore => ownedSummary?.purchaseStore;
  DateTime? get purchaseDate => ownedSummary?.purchaseDate;
  DateTime? get soldAt => ownedSummary?.soldAt;
  String? get personalNotes => ownedSummary?.notes;
}
