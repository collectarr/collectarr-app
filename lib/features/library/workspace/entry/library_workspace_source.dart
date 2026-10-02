import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_collection_item_dispatch.dart';
import 'library_workspace_catalog_data.dart';

/// Concrete workspace source used after kind dispatch.
///
/// Mixed/global Shelf consumers use [CatalogDisplaySummary],
/// [CollectionItemSummary] and refs. Kind-dispatched workspace pages receive the
/// owning kind's structural catalog data; transport DTOs do not cross this
/// workspace boundary.
final class LibraryWorkspaceSource {
  const LibraryWorkspaceSource({
    required this.itemId,
    this.catalogSummary,
    this.collectionItemSummary,
    this.trackingSummary,
    this.trackingSummaries = const <TrackingSummary>[],
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.fallbackOwnerLabel,
    this.catalogSearchTokens = const <String>[],
    this.catalogData,
    this.collectionItemDispatch,
  });

  final String itemId;
  final CatalogDisplaySummary? catalogSummary;
  final CollectionItemSummary? collectionItemSummary;
  final TrackingSummary? trackingSummary;
  final List<TrackingSummary> trackingSummaries;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final String? fallbackOwnerLabel;

  /// Kind-owned catalog graph projected into a structural workspace boundary.
  ///
  /// The concrete value is created by the owning kind's transport codec. Mixed
  /// Shelf code may read only the structural members of this interface.
  final LibraryWorkspaceCatalogData? catalogData;

  /// Concrete kind-owned aggregate behind an explicit typed dispatch
  /// boundary. Mixed/global callers must use [collectionItemSummary] instead.
  final LibraryCollectionItemDispatch? collectionItemDispatch;

  /// Structural search tokens captured at the catalog boundary. Generic
  /// search may index these values but never inspects the transport payload.
  final List<String> catalogSearchTokens;

  CatalogEntityRef? get catalogRef {
    final sourceRef =
        catalogSummary?.ref ?? catalogData?.ref ?? collectionItemSummary?.catalogRef;
    if (sourceRef != null) return sourceRef;
    final wishlistRef = wishlistItem?.catalogRef;
    if (wishlistRef == null) return null;
    return CatalogEntityRef(
      kind: wishlistRef.kind,
      entityType: CatalogEntityTypeId.catalogItem,
      id: wishlistRef.id,
    );
  }

  CatalogMediaKind get mediaKind =>
      catalogSummary?.kind ??
      catalogData?.kind ??
      collectionItemSummary?.ref.kind ??
      wishlistItem?.catalogRef.kind ??
      CatalogMediaKind.unknown;

  CollectionItemRef? get collectionItemRef => collectionItemSummary?.ref;

  bool get isOwned => collectionItemSummary != null;
  bool get isTracked => trackingSummary != null || trackingSummaries.isNotEmpty;
  bool get isWishlisted => wishlistItem != null;

  TrackingSummary? trackingSummaryFor(CatalogEntityRef target) {
    for (final summary in trackingSummaries) {
      if (summary.catalogRef == target) return summary;
    }
    return trackingSummary?.catalogRef == target ? trackingSummary : null;
  }

  String get subtitle {
    if (isOwned && isWishlisted) return 'Owned and wishlisted';
    if (isOwned) return 'Owned';
    if (isTracked) return 'Tracked';
    return 'Wishlist';
  }

  bool get hasNotes =>
      (collectionItemSummary?.hasNotes ?? false) ||
      (wishlistItem?.notes?.trim().isNotEmpty ?? false);

  DateTime get updatedAt {
    final values = <DateTime>[
      if (collectionItemSummary?.updatedAt case final value?) value,
      if (trackingSummary?.updatedAt case final value?) value,
      if (wishlistItem?.updatedAt case final value?) value,
    ];
    if (values.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  DateTime? get addedAt => collectionItemSummary?.createdAt ?? wishlistItem?.createdAt;

  String get title {
    final value = catalogSummary?.primaryLabel.trim();
    if (value != null && value.isNotEmpty) return value;
    final catalogValue = catalogData?.title.trim();
    if (catalogValue != null && catalogValue.isNotEmpty) return catalogValue;
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

  String? get ownerLabel => collectionItemSummary?.ownerLabel ?? fallbackOwnerLabel;

  int? get pricePaidCents => collectionItemSummary?.pricePaidCents;
  int? get sellPriceCents => collectionItemSummary?.sellPriceCents;
  int? get marketValueCents => collectionItemSummary?.marketValueCents;
  String? get soldTo => collectionItemSummary?.soldTo;
  String? get currency => collectionItemSummary?.currency;
  String? get purchaseStore => collectionItemSummary?.purchaseStore;
  DateTime? get purchaseDate => collectionItemSummary?.purchaseDate;
  DateTime? get soldAt => collectionItemSummary?.soldAt;
  String? get personalNotes => collectionItemSummary?.notes;
}
