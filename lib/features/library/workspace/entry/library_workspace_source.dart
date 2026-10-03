import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'library_workspace_catalog_data.dart';

/// Concrete workspace source used after kind dispatch.
///
/// Mixed/global Shelf consumers use [CatalogDisplaySummary],
/// [LibraryEntrySummary] and refs. Kind-dispatched workspace pages receive the
/// owning kind's structural catalog data; transport DTOs do not cross this
/// workspace boundary.
final class LibraryWorkspaceSource {
  const LibraryWorkspaceSource({
    required this.itemId,
    this.catalogSummary,
    this.libraryEntrySummary,
    this.trackingSummary,
    this.trackingSummaries = const <TrackingSummary>[],
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.userExternalLinks = const <UserExternalLink>[],
    this.loans = const <Loan>[],
    this.folderMemberships = const <({String folderId, int sortOrder})>[],
    this.folderDefinitions = const <UserFolder>[],
    this.readingQueuePosition,
    this.fallbackOwnerLabel,
    this.catalogSearchTokens = const <String>[],
    this.catalogData,
    this.libraryEntryDispatch,
    this.persistedEntryPayload,
  });

  final String itemId;
  final CatalogDisplaySummary? catalogSummary;
  final LibraryEntrySummary? libraryEntrySummary;
  final TrackingSummary? trackingSummary;
  final List<TrackingSummary> trackingSummaries;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final List<UserExternalLink> userExternalLinks;
  final List<Loan> loans;
  final List<({String folderId, int sortOrder})> folderMemberships;
  final List<UserFolder> folderDefinitions;
  final int? readingQueuePosition;
  final String? fallbackOwnerLabel;

  /// Kind-entry catalog graph projected into a structural workspace boundary.
  ///
  /// The concrete value is created by the owning kind's transport codec. Mixed
  /// Shelf code may read only the structural members of this interface.
  final LibraryWorkspaceCatalogData? catalogData;

  /// Concrete kind-entry aggregate behind an explicit typed dispatch
  /// boundary. Mixed/global callers must use [libraryEntrySummary] instead.
  final LibraryEntryDispatch? libraryEntryDispatch;

  /// Complete local envelope captured for lossless export and diagnostics.
  final Map<String, dynamic>? persistedEntryPayload;

  /// Structural search tokens captured at the catalog boundary. Generic
  /// search may index these values but never inspects the transport payload.
  final List<String> catalogSearchTokens;

  CatalogEntityRef? get catalogRef {
    final sourceRef = catalogSummary?.ref ??
        catalogData?.ref ??
        libraryEntrySummary?.ref.localCatalogItemRef;
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
      libraryEntrySummary?.ref.kind ??
      wishlistItem?.catalogRef.kind ??
      CatalogMediaKind.unknown;

  LibraryEntryRef? get libraryEntryRef => libraryEntrySummary?.ref;

  bool get isEntry => libraryEntrySummary != null;
  bool get isTracked => trackingSummary != null || trackingSummaries.isNotEmpty;
  bool get isWishlisted => wishlistItem != null;

  TrackingSummary? trackingSummaryFor(LibraryEntryRef target) {
    for (final summary in trackingSummaries) {
      if (summary.libraryEntryRef == target) return summary;
    }
    return trackingSummary?.libraryEntryRef == target ? trackingSummary : null;
  }

  String get subtitle {
    if (isEntry && isWishlisted) return 'Entry and wishlisted';
    if (isEntry) return 'Entry';
    if (isTracked) return 'Tracked';
    return 'Wishlist';
  }

  bool get hasNotes =>
      (libraryEntrySummary?.hasNotes ?? false) ||
      (wishlistItem?.notes?.trim().isNotEmpty ?? false);

  DateTime get updatedAt {
    final values = <DateTime>[
      if (libraryEntrySummary?.updatedAt case final value?) value,
      if (trackingSummary?.updatedAt case final value?) value,
      if (wishlistItem?.updatedAt case final value?) value,
    ];
    if (values.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  DateTime? get addedAt =>
      libraryEntrySummary?.createdAt ?? wishlistItem?.createdAt;

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

  String? get ownerLabel =>
      libraryEntrySummary?.ownerLabel ?? fallbackOwnerLabel;

  int? get pricePaidCents => libraryEntrySummary?.pricePaidCents;
  int? get sellPriceCents => libraryEntrySummary?.sellPriceCents;
  int? get marketValueCents => libraryEntrySummary?.marketValueCents;
  String? get soldTo => libraryEntrySummary?.soldTo;
  String? get currency => libraryEntrySummary?.currency;
  String? get purchaseStore => libraryEntrySummary?.purchaseStore;
  DateTime? get purchaseDate => libraryEntrySummary?.purchaseDate;
  DateTime? get soldAt => libraryEntrySummary?.soldAt;
  String? get personalNotes => libraryEntrySummary?.notes;
}
