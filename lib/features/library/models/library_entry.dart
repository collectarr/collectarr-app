import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';

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

  MediaTracking get tracking =>
      trackingSummary?.tracking ??
      const MediaTracking(status: MediaTrackingStatus.none);

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

/// Small mixed-Shelf tracking projection.
final class TrackingSummary {
  const TrackingSummary({
    required this.catalogRef,
    required this.tracking,
    required this.updatedAt,
    this.deletedAt,
  });

  factory TrackingSummary.fromEntry(TrackingEntry entry) {
    return TrackingSummary(
      catalogRef: entry.catalogRef,
      tracking: entry.mediaTracking,
      updatedAt: entry.updatedAt,
      deletedAt: entry.deletedAt,
    );
  }

  final CatalogEntityRef catalogRef;
  final MediaTracking tracking;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
  String get statusLabel => tracking.statusLabel;
}

/// Complete source used after a kind has been selected by the Library
/// workspace. It is separate from [LibraryEntry], the mixed projection.
class LibraryWorkspaceEntry extends LibraryEntry {
  const LibraryWorkspaceEntry({
    required super.itemId,
    super.catalogSummary,
    super.ownedSummary,
    super.trackingSummary,
    super.wishlistItem,
    super.locationPath,
    super.watchSessions,
    super.itemImages,
    super.fallbackOwnerLabel,
    this.catalogItem,
    this.ownedItem,
    this.trackingEntry,
  });

  final CatalogItemDto? catalogItem;
  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;

  Object? get kindMetadata => catalogItem?.kindMetadata;

  @override
  bool get isOwned => ownedSummary != null || ownedItem != null;

  @override
  bool get isTracked => trackingSummary != null || trackingEntry != null;

  @override
  bool get hasNotes =>
      (ownedSummary?.hasNotes ??
          ownedItem?.personalNotes?.trim().isNotEmpty == true) ||
      (wishlistItem?.notes?.trim().isNotEmpty ?? false);

  @override
  DateTime get updatedAt {
    final values = <DateTime>[
      if (ownedSummary?.updatedAt case final value?) value,
      if (trackingSummary?.updatedAt case final value?) value,
      if (wishlistItem?.updatedAt case final value?) value,
      if (ownedItem?.updatedAt case final value?) value,
      if (trackingEntry?.updatedAt case final value?) value,
    ];
    if (values.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  @override
  DateTime? get addedAt =>
      ownedSummary?.createdAt ??
      ownedItem?.createdAt ??
      wishlistItem?.createdAt;

  @override
  String get title {
    final value = catalogSummary?.title.trim();
    if (value != null && value.isNotEmpty) return value;
    final legacyTitle = catalogItem?.resolvedDisplayTitle.trim();
    if (legacyTitle != null && legacyTitle.isNotEmpty) return legacyTitle;
    final length = itemId.length < 8 ? itemId.length : 8;
    return 'Catalog item ${itemId.substring(0, length)}';
  }

  @override
  MediaTracking get tracking =>
      trackingSummary?.tracking ??
      const MediaTracking(status: MediaTrackingStatus.none);

  @override
  String? get ownerLabel =>
      ownedSummary?.ownerLabel ?? ownedItem?.ownerLabel ?? fallbackOwnerLabel;

  @override
  int get quantity => ownedSummary?.quantity ?? ownedItem?.quantity ?? 0;

  // These fields remain available only on the post-dispatch workspace source.
  String? get condition => ownedItem?.condition;
  String? get grade => ownedItem?.grade;
  int? get pricePaidCents =>
      ownedSummary?.pricePaidCents ?? ownedItem?.pricePaidCents;
  int? get marketValueCents => ownedItem?.marketValueCents;
  String? get currency => ownedSummary?.currency ?? ownedItem?.currency;
  String? get purchaseStore =>
      ownedSummary?.purchaseStore ?? ownedItem?.purchaseStore;
  DateTime? get purchaseDate =>
      ownedSummary?.purchaseDate ?? ownedItem?.purchaseDate;
  String? get personalNotes => ownedSummary?.notes ?? ownedItem?.personalNotes;
  String? get tags => ownedItem?.tags;

  List<String> get tagList {
    final raw = tags?.trim();
    if (raw == null || raw.isEmpty) return const <String>[];
    return raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}
