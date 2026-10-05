import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';

/// Personal state that can coexist with a Catalog Item or local entry.
final class PersonalOverlay {
  const PersonalOverlay({
    this.tracking,
    this.trackingSummaries = const <TrackingSummary>[],
    this.wishlist,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.images = const <ItemImage>[],
    this.externalLinks = const <UserExternalLink>[],
    this.loans = const <Loan>[],
    this.folderMemberships = const <({String folderId, int sortOrder})>[],
    this.folderDefinitions = const <UserFolder>[],
    this.readingQueuePosition,
    this.fallbackOwnerLabel,
  });

  final TrackingSummary? tracking;
  final List<TrackingSummary> trackingSummaries;
  final WishlistItem? wishlist;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> images;
  final List<UserExternalLink> externalLinks;
  final List<Loan> loans;
  final List<({String folderId, int sortOrder})> folderMemberships;
  final List<UserFolder> folderDefinitions;
  final int? readingQueuePosition;
  final String? fallbackOwnerLabel;

  CatalogItemRef? get wishlistCatalogRef => wishlist?.catalogRef;
  bool get isTracked => tracking != null || trackingSummaries.isNotEmpty;
  bool get isWishlisted => wishlist != null;

  TrackingSummary? trackingSummaryFor(LibraryEntryRef target) {
    for (final summary in trackingSummaries) {
      if (summary.libraryEntryRef == target) return summary;
    }
    return tracking?.libraryEntryRef == target ? tracking : null;
  }

  DateTime get updatedAt {
    final values = <DateTime>[
      if (tracking?.updatedAt case final value?) value,
      for (final summary in trackingSummaries) summary.updatedAt,
      if (wishlist?.updatedAt case final value?) value,
    ];
    if (values.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  String? get ownerLabel => fallbackOwnerLabel;
  bool get hasNotes => wishlist?.notes?.trim().isNotEmpty ?? false;
}
