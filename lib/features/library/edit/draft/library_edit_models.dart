import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

// ---------------------------------------------------------------------------
// Selection data classes returned by the edit dialog
// ---------------------------------------------------------------------------

enum LibraryEditSubmitAction {
  save,
  saveAndNext,
}

class LibraryEditSelection {
  const LibraryEditSelection({
    required this.item,
    required this.personal,
    this.scope = LibraryEditScope.media,
    this.wishlist,
    this.tracking,
    this.customFieldEdits = const {},
    this.itemImageEdits = const [],
    this.submitAction = LibraryEditSubmitAction.save,
  });

  final LibraryMetadataItem item;
  final LibraryPersonalEditSelection? personal;
  final LibraryEditScope scope;
  final LibraryWishlistEditSelection? wishlist;
  final LibraryTrackingEditSelection? tracking;
  final Map<String, String?> customFieldEdits;
  final List<ItemImageEdit> itemImageEdits;
  final LibraryEditSubmitAction submitAction;

  LibraryEditSelection copyWith({
    LibraryMetadataItem? item,
    LibraryPersonalEditSelection? personal,
    LibraryEditScope? scope,
    LibraryWishlistEditSelection? wishlist,
    LibraryTrackingEditSelection? tracking,
    Map<String, String?>? customFieldEdits,
    List<ItemImageEdit>? itemImageEdits,
    LibraryEditSubmitAction? submitAction,
  }) {
    return LibraryEditSelection(
      item: item ?? this.item,
      personal: personal ?? this.personal,
      scope: scope ?? this.scope,
      wishlist: wishlist ?? this.wishlist,
      tracking: tracking ?? this.tracking,
      customFieldEdits: customFieldEdits ?? this.customFieldEdits,
      itemImageEdits: itemImageEdits ?? this.itemImageEdits,
      submitAction: submitAction ?? this.submitAction,
    );
  }
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
    this.quantity = 1,
    required this.indexNumber,
    required this.locationId,
    this.locationChanged = false,
    required this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.keyComic,
    this.keyReason,
    this.keyCategory,
    this.keySeverity,
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
    this.dustJacketPresent,
    this.dustJacketCondition,
    this.collectionStatus,
    this.lastBagBoardDate,
    this.marketValueCents,
    this.ownerLabel,
    this.gameCompleteness,
    this.gameHasBox,
    this.gameHasManual,
    this.gamePriceChartingId,
    this.gameCoreRegion,
    this.gameValueIsLocked,
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
  final int? indexNumber;
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
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool? keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
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
  final bool? dustJacketPresent;
  final String? dustJacketCondition;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? marketValueCents;
  final String? ownerLabel;
  final String? gameCompleteness;
  final bool? gameHasBox;
  final bool? gameHasManual;
  final String? gamePriceChartingId;
  final String? gameCoreRegion;
  final bool? gameValueIsLocked;

  LibraryPersonalEditSelection copyWith({
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    int? indexNumber,
    String? locationId,
    bool? locationChanged,
    String? tags,
    DateTime? soldAt,
    int? sellPriceCents,
    String? soldTo,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    String? labelType,
    String? customLabel,
    String? pageQuality,
    String? certificationNumber,
    bool? keyComic,
    String? keyReason,
    String? keyCategory,
    String? keySeverity,
    int? coverPriceCents,
    String? features,
    List<String>? hdrFormats,
    String? purchaseStore,
    String? boxSetName,
    String? storageDevice,
    String? storageSlot,
    String? region,
    String? packaging,
    String? distributor,
    String? screenRatio,
    String? audioTracks,
    String? subtitles,
    String? layers,
    String? color,
    int? nrDiscs,
    bool? dustJacketPresent,
    String? dustJacketCondition,
    String? collectionStatus,
    DateTime? lastBagBoardDate,
    int? marketValueCents,
    String? ownerLabel,
    String? gameCompleteness,
    bool? gameHasBox,
    bool? gameHasManual,
    String? gamePriceChartingId,
    String? gameCoreRegion,
    bool? gameValueIsLocked,
  }) {
    return LibraryPersonalEditSelection(
      anchorType: anchorType ?? this.anchorType,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      indexNumber: indexNumber ?? this.indexNumber,
      locationId: locationId ?? this.locationId,
      locationChanged: locationChanged ?? this.locationChanged,
      tags: tags ?? this.tags,
      soldAt: soldAt ?? this.soldAt,
      sellPriceCents: sellPriceCents ?? this.sellPriceCents,
      soldTo: soldTo ?? this.soldTo,
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      labelType: labelType ?? this.labelType,
      customLabel: customLabel ?? this.customLabel,
      pageQuality: pageQuality ?? this.pageQuality,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      keyCategory: keyCategory ?? this.keyCategory,
      keySeverity: keySeverity ?? this.keySeverity,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      features: features ?? this.features,
      hdrFormats: hdrFormats ?? this.hdrFormats,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      boxSetName: boxSetName ?? this.boxSetName,
      storageDevice: storageDevice ?? this.storageDevice,
      storageSlot: storageSlot ?? this.storageSlot,
      region: region ?? this.region,
      packaging: packaging ?? this.packaging,
      distributor: distributor ?? this.distributor,
      screenRatio: screenRatio ?? this.screenRatio,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitles: subtitles ?? this.subtitles,
      layers: layers ?? this.layers,
      color: color ?? this.color,
      nrDiscs: nrDiscs ?? this.nrDiscs,
      dustJacketPresent: dustJacketPresent ?? this.dustJacketPresent,
      dustJacketCondition: dustJacketCondition ?? this.dustJacketCondition,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      lastBagBoardDate: lastBagBoardDate ?? this.lastBagBoardDate,
      marketValueCents: marketValueCents ?? this.marketValueCents,
      ownerLabel: ownerLabel ?? this.ownerLabel,
      gameCompleteness: gameCompleteness ?? this.gameCompleteness,
      gameHasBox: gameHasBox ?? this.gameHasBox,
      gameHasManual: gameHasManual ?? this.gameHasManual,
      gamePriceChartingId: gamePriceChartingId ?? this.gamePriceChartingId,
      gameCoreRegion: gameCoreRegion ?? this.gameCoreRegion,
      gameValueIsLocked: gameValueIsLocked ?? this.gameValueIsLocked,
    );
  }
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

  LibraryTrackingEditSelection copyWith({
    String? editionId,
    String? variantId,
    int? rating,
    String? readStatus,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    int? seasonNumber,
    int? episodeNumber,
    DateTime? startedAt,
    DateTime? finishedAt,
    Map<String, int>? episodeRatings,
  }) {
    return LibraryTrackingEditSelection(
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      notes: notes ?? this.notes,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      episodeRatings: episodeRatings ?? this.episodeRatings,
    );
  }
}
