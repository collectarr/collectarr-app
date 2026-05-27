import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

// ---------------------------------------------------------------------------
// Selection data classes returned by the edit dialog
// ---------------------------------------------------------------------------

class LibraryEditSelection {
  const LibraryEditSelection({
    required this.item,
    required this.personal,
    this.wishlist,
    this.tracking,
    this.customFieldEdits = const {},
    this.itemImageEdits = const [],
  });

  final LibraryMetadataItem item;
  final LibraryPersonalEditSelection? personal;
  final LibraryWishlistEditSelection? wishlist;
  final LibraryTrackingEditSelection? tracking;
  final Map<String, String?> customFieldEdits;
  final List<ItemImageEdit> itemImageEdits;
}

class LibraryPersonalEditSelection {
  const LibraryPersonalEditSelection({
    required this.anchorType,
    required this.editionId,
    required this.variantId,
    required this.bundleReleaseId,
    required this.condition,
    required this.grade,
    required this.purchaseDate,
    required this.pricePaidCents,
    required this.currency,
    required this.personalNotes,
    required this.quantity,
    required this.locationId,
    required this.locationChanged,
    required this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.keyComic,
    this.keyReason,
    this.coverPriceCents,
    this.features,
    this.hdrFormats,
    this.purchaseStore,
    this.boxSetName,
    this.storageDevice,
    this.storageSlot,
    this.region,
    this.packaging,
    this.distributor,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.color,
    this.nrDiscs,
    this.collectionStatus,
    this.lastBagBoardDate,
    this.marketValueCents,
  });

  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? locationId;
  final bool locationChanged;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool? keyComic;
  final String? keyReason;
  final int? coverPriceCents;
  final String? features;
  final List<String>? hdrFormats;
  final String? purchaseStore;
  final String? boxSetName;
  final String? storageDevice;
  final String? storageSlot;
  final String? region;
  final String? packaging;
  final String? distributor;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? color;
  final int? nrDiscs;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? marketValueCents;
}

class LibraryWishlistEditSelection {
  const LibraryWishlistEditSelection({
    required this.anchorType,
    required this.editionId,
    required this.variantId,
    required this.bundleReleaseId,
    required this.targetPriceCents,
    required this.currency,
    required this.notes,
  });

  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
}

class LibraryTrackingEditSelection {
  const LibraryTrackingEditSelection({
    required this.editionId,
    required this.variantId,
    required this.rating,
    required this.readStatus,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    this.notes,
    this.seasonNumber,
    this.episodeNumber,
    this.startedAt,
    this.finishedAt,
    this.episodeRatings,
  });

  final String? editionId;
  final String? variantId;
  final int? rating;
  final String? readStatus;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final int? seasonNumber;
  final int? episodeNumber;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final Map<String, int>? episodeRatings;
}
