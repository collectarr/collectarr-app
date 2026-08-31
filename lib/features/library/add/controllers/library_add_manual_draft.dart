import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:flutter/material.dart';

/// Generic personal and session state for the manual Add dialog flow.
///
/// Kind-specific fields are owned by [kindDraft] implementing [LibraryKindAddDraft].
class LibraryAddManualDraft {
  LibraryAddManualDraft({
    required List<CustomFieldValue> customFieldValues,
    required List<ItemImage> itemImages,
    required this.kindDraft,
  })  : customFieldValues = Map.fromEntries(
          customFieldValues.map(
            (value) => MapEntry(value.fieldDefinitionId, value.value),
          ),
        ),
        itemImages = List<ItemImage>.of(itemImages);

  final LibraryKindAddDraft kindDraft;

  final titleController = TextEditingController();
  final tagsController = TextEditingController();
  final personalNotesController = TextEditingController();
  final coverPriceController = TextEditingController();
  final priceController = TextEditingController();
  final purchaseDateController = TextEditingController();
  final purchaseStoreController = TextEditingController();
  final sellPriceController = TextEditingController();
  final soldDateController = TextEditingController();
  final ownerLabelController = TextEditingController();
  final linksController = TextEditingController();

  Map<String, String?> customFieldValues;
  List<ItemImage> itemImages;
  LibraryCoverScanResult? coverScanPrefill;
  DateTime? soldAt;

  void dispose() {
    titleController.dispose();
    tagsController.dispose();
    personalNotesController.dispose();
    coverPriceController.dispose();
    priceController.dispose();
    purchaseDateController.dispose();
    purchaseStoreController.dispose();
    sellPriceController.dispose();
    soldDateController.dispose();
    ownerLabelController.dispose();
    linksController.dispose();
    kindDraft.dispose();
  }
}
