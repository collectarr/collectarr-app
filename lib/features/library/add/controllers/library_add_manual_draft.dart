import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/library_add_registry.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:flutter/material.dart';

class LibraryAddManualDraft {
  LibraryAddManualDraft({
    required List<CustomFieldValue> customFieldValues,
    required List<ItemImage> itemImages,
  })  : customFieldValues = Map.fromEntries(
          customFieldValues.map(
            (value) => MapEntry(value.fieldDefinitionId, value.value),
          ),
        ),
        itemImages = List<ItemImage>.of(itemImages);

  final titleController = TextEditingController();
  final numberController = TextEditingController();
  final publisherController = TextEditingController();
  final yearController = TextEditingController();
  final variantController = TextEditingController();
  final physicalFormatLabelController = TextEditingController();
  final coverController = TextEditingController();
  final backCoverController = TextEditingController();
  final creatorsController = TextEditingController();
  final charactersController = TextEditingController();
  final linksController = TextEditingController();
  final editionTitleController = TextEditingController();
  final releaseDateController = TextEditingController();
  final pageCountController = TextEditingController();
  final imprintController = TextEditingController();
  final seriesGroupController = TextEditingController();
  final countryController = TextEditingController();
  final languageController = TextEditingController();
  final ageRatingController = TextEditingController();
  final genresEditController = TextEditingController();
  final synopsisController = TextEditingController();
  final tagsController = TextEditingController();
  final personalNotesController = TextEditingController();
  final rawOrSlabbedController = TextEditingController();
  final gradingCompanyController = TextEditingController();
  final graderNotesController = TextEditingController();
  final signedByController = TextEditingController();
  final labelTypeController = TextEditingController();
  final certificationNumberController = TextEditingController();
  final coverPriceController = TextEditingController();
  final priceController = TextEditingController();
  final purchaseDateController = TextEditingController();
  final purchaseStoreController = TextEditingController();
  final sellPriceController = TextEditingController();
  final soldDateController = TextEditingController();
  final ownerLabelController = TextEditingController();

  Map<String, dynamic> kindSpecific = {};
  Map<String, dynamic> kindSpecificFactoryValues = {};
  final Set<TextEditingController> createdControllers = {};
  List<SeriesRegistryEntry> seriesEntries = const [];
  List<String> publisherOptions = const [];
  List<String> imprintOptions = const [];
  List<String> seriesGroupOptions = const [];
  List<String> physicalFormatOptions = const [];
  Map<String, String?> customFieldValues;
  List<ItemImage> itemImages;
  LibraryCoverScanResult? coverScanPrefill;
  String? selectedSeriesId;
  DateTime? soldAt;

  TextEditingController controllerFor(
    String key,
    TextEditingController fallback,
  ) {
    final controller = kindSpecific[key];
    return controller is TextEditingController ? controller : fallback;
  }

  void disposeKindSpecificFactoryValues() {
    for (final controller in createdControllers) {
      try {
        controller.dispose();
      } catch (_) {}
    }
    createdControllers.clear();
    kindSpecificFactoryValues = {};
  }

  void dispose() {
    titleController.dispose();
    numberController.dispose();
    publisherController.dispose();
    yearController.dispose();
    variantController.dispose();
    physicalFormatLabelController.dispose();
    coverController.dispose();
    backCoverController.dispose();
    creatorsController.dispose();
    charactersController.dispose();
    linksController.dispose();
    editionTitleController.dispose();
    releaseDateController.dispose();
    pageCountController.dispose();
    imprintController.dispose();
    seriesGroupController.dispose();
    countryController.dispose();
    languageController.dispose();
    ageRatingController.dispose();
    genresEditController.dispose();
    synopsisController.dispose();
    tagsController.dispose();
    personalNotesController.dispose();
    rawOrSlabbedController.dispose();
    gradingCompanyController.dispose();
    graderNotesController.dispose();
    signedByController.dispose();
    labelTypeController.dispose();
    certificationNumberController.dispose();
    coverPriceController.dispose();
    priceController.dispose();
    purchaseDateController.dispose();
    purchaseStoreController.dispose();
    sellPriceController.dispose();
    soldDateController.dispose();
    ownerLabelController.dispose();
    disposeKindSpecificFactoryValues();
  }

  void syncKindSpecificFactoryValues(CatalogMediaKind kind) {
    final factory = LibraryAddRegistry.manualKindSpecificFactoryFor(kind);
    if (factory == null) {
      if (kindSpecificFactoryValues.isNotEmpty ||
          createdControllers.isNotEmpty) {
        disposeKindSpecificFactoryValues();
      }
      return;
    }
    if (kindSpecificFactoryValues.isNotEmpty) {
      return;
    }
    final factoryMap = factory();
    for (final value in factoryMap.values) {
      if (value is TextEditingController) {
        createdControllers.add(value);
      }
    }
    kindSpecificFactoryValues = factoryMap;
  }

  Map<String, dynamic> buildKindSpecificMap(
    Map<String, dynamic> baseValues,
  ) {
    kindSpecific = Map<String, dynamic>.from(baseValues)
      ..addAll(kindSpecificFactoryValues);
    return kindSpecific;
  }
}
