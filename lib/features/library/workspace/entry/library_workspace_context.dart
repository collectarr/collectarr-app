import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';

import '../../domain/library_target_ref.dart';
import 'personal_overlay.dart';
import 'workspace_item.dart';

/// A row-level view assembled from independently owned workspace and personal
/// data. This context stores no duplicate values or inferred identity.
final class LibraryWorkspaceContext {
  const LibraryWorkspaceContext({required this.item, required this.personal});

  final WorkspaceItem item;
  final PersonalOverlay personal;

  LibraryTargetRef get target => item.target;
  String get itemId => item.id;
  CatalogDisplaySummary? get catalogSummary => item.presentation;
  Object? get kindPresentationData => item.kindPresentationData;
  List<String> get catalogSearchTokens => item.searchTokens;
  CatalogMediaKind get mediaKind => item.kind;
  String get title => item.title;

  LibraryEntrySummary? get libraryEntrySummary => item.entrySummary;
  TrackingSummary? get trackingSummary => personal.tracking;
  List<TrackingSummary> get trackingSummaries => personal.trackingSummaries;
  WishlistItem? get wishlistItem => personal.wishlist;
  String? get locationPath => personal.locationPath;
  List<WatchSession> get watchSessions => personal.watchSessions;
  List<ItemImage> get itemImages => personal.images;
  List<UserExternalLink> get userExternalLinks => personal.externalLinks;
  List<Loan> get loans => personal.loans;
  List<({String folderId, int sortOrder})> get folderMemberships =>
      personal.folderMemberships;
  List<UserFolder> get folderDefinitions => personal.folderDefinitions;
  int? get readingQueuePosition => personal.readingQueuePosition;
  String? get fallbackOwnerLabel => personal.fallbackOwnerLabel;
  LibraryEntryDispatch? get libraryEntryDispatch => item.libraryEntryDispatch;

  CatalogItemRef? get sourceCatalogRef => libraryEntrySummary?.sourceCatalogRef;
  CatalogItemRef? get wishlistCatalogRef => personal.wishlistCatalogRef;
  LibraryEntryRef? get libraryEntryRef => libraryEntrySummary?.ref;
  bool get isEntry => libraryEntrySummary != null;
  bool get isTracked => personal.isTracked;
  bool get isWishlisted => personal.isWishlisted;
  DateTime get updatedAt {
    final entryUpdatedAt = libraryEntrySummary?.updatedAt;
    if (entryUpdatedAt == null || !entryUpdatedAt.isAfter(personal.updatedAt)) {
      return personal.updatedAt;
    }
    return entryUpdatedAt;
  }

  DateTime? get addedAt =>
      libraryEntrySummary?.createdAt ?? personal.wishlist?.createdAt;
  bool get hasNotes =>
      (libraryEntrySummary?.hasNotes ?? false) || personal.hasNotes;

  TrackingSummary? trackingSummaryFor(LibraryEntryRef target) =>
      personal.trackingSummaryFor(target);

  String get subtitle {
    if (isEntry && isWishlisted) return 'Entry and wishlisted';
    if (isEntry) return 'Entry';
    if (isTracked) return 'Tracked';
    return 'Wishlist';
  }

  MediaTrackingStatus get trackingStatus =>
      trackingSummary?.status ?? MediaTrackingStatus.none;
  int? get trackingRating => trackingSummary?.rating;
  DateTime? get trackingStartedAt => trackingSummary?.startedAt;
  DateTime? get trackingCompletedAt => trackingSummary?.completedAt;
  String? get trackingNotes => trackingSummary?.notes;
  String get trackingStatusLabel => trackingStatus.label;

  String? get ownerLabel =>
      libraryEntrySummary?.ownerLabel ?? personal.ownerLabel;
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
