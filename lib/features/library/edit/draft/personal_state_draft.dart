import 'package:collectarr_app/core/models/catalog_item_ref.dart';
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
    required this.indexNumberController,
    required this.notesController,
    required this.purchaseStoreController,
    required this.marketValueController,
    required this.wishlistPriceController,
    required this.wishlistCurrencyController,
    required this.wishlistNotesController,
    required this.tagsController,
    required this.sellPriceController,
    required this.soldToController,
    required this.tagOptions,
    required this.availableLocations,
    required this.selectedLocationId,
    required this.selectedWishlistCatalogRef,
    required this.locationChanged,
    required this.soldAt,
    required this.collectionStatus,
  });

  final TextEditingController ownerLabelController;
  final TextEditingController conditionController;
  final TextEditingController gradeController;
  final TextEditingController purchaseDateController;
  final TextEditingController priceController;
  final TextEditingController currencyController;
  final TextEditingController indexNumberController;
  final TextEditingController notesController;
  final TextEditingController purchaseStoreController;
  final TextEditingController marketValueController;
  final TextEditingController wishlistPriceController;
  final TextEditingController wishlistCurrencyController;
  final TextEditingController wishlistNotesController;
  final TextEditingController tagsController;
  final TextEditingController sellPriceController;
  final TextEditingController soldToController;

  List<String> tagOptions;
  List<StorageLocation> availableLocations;
  String? selectedLocationId;

  CatalogItemRef? selectedWishlistCatalogRef;

  bool locationChanged;
  DateTime? soldAt;
  String? collectionStatus;

  String? get selectedLocationName {
    if (selectedLocationId == null) return null;
    return availableLocations
        .where((loc) => loc.id == selectedLocationId)
        .firstOrNull
        ?.name;
  }

  String? get selectedLocationPath {
    if (selectedLocationId == null) return null;
    return availableLocations
        .where((location) => location.id == selectedLocationId)
        .firstOrNull
        ?.fullPath(availableLocations);
  }
}
