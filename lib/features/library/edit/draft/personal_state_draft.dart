import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:flutter/material.dart';

class PersonalStateDraft {
  PersonalStateDraft({
    required this.ownerLabelController,
    required this.conditionController,
    required this.gradeController,
    required this.purchaseDateController,
    required this.priceController,
    required this.currencyController,
    required this.quantityController,
    required this.indexNumberController,
    required this.notesController,
    required this.purchaseStoreController,
    required this.marketValueController,
    required this.wishlistPriceController,
    required this.wishlistCurrencyController,
    required this.wishlistNotesController,
    required this.ratingController,
    required this.trackingController,
    required this.progressCurrentController,
    required this.progressTotalController,
    required this.timesCompletedController,
    required this.seasonNumberController,
    required this.episodeNumberController,
    required this.trackingNotesController,
    required this.tagsController,
    required this.sellPriceController,
    required this.soldToController,
    required this.tagOptions,
    required this.availableLocations,
    required this.selectedLocationId,
    required this.selectedOwnedAnchorType,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.selectedBundleReleaseId,
    required this.selectedTrackingEditionId,
    required this.selectedTrackingVariantId,
    required this.selectedWishlistAnchorType,
    required this.selectedWishlistEditionId,
    required this.selectedWishlistVariantId,
    required this.selectedWishlistBundleReleaseId,
    required this.locationChanged,
    required this.soldAt,
    required this.startedAt,
    required this.finishedAt,
    required this.episodeRatings,
    required this.collectionStatus,
  });

  final TextEditingController ownerLabelController;
  final TextEditingController conditionController;
  final TextEditingController gradeController;
  final TextEditingController purchaseDateController;
  final TextEditingController priceController;
  final TextEditingController currencyController;
  final TextEditingController quantityController;
  final TextEditingController indexNumberController;
  final TextEditingController notesController;
  final TextEditingController purchaseStoreController;
  final TextEditingController marketValueController;
  final TextEditingController wishlistPriceController;
  final TextEditingController wishlistCurrencyController;
  final TextEditingController wishlistNotesController;
  final TextEditingController ratingController;
  final TextEditingController trackingController;
  final TextEditingController progressCurrentController;
  final TextEditingController progressTotalController;
  final TextEditingController timesCompletedController;
  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  final TextEditingController trackingNotesController;
  final TextEditingController tagsController;
  final TextEditingController sellPriceController;
  final TextEditingController soldToController;

  List<String> tagOptions;
  List<StorageLocation> availableLocations;
  String? selectedLocationId;
  PersonalItemAnchorType selectedOwnedAnchorType;
  String? selectedEditionId;
  String? selectedVariantId;
  String? selectedBundleReleaseId;

  String? selectedTrackingEditionId;
  String? selectedTrackingVariantId;

  PersonalItemAnchorType selectedWishlistAnchorType;
  String? selectedWishlistEditionId;
  String? selectedWishlistVariantId;
  String? selectedWishlistBundleReleaseId;

  bool locationChanged;
  DateTime? soldAt;
  DateTime? startedAt;
  DateTime? finishedAt;
  Map<String, int> episodeRatings;
  String? collectionStatus;
}
