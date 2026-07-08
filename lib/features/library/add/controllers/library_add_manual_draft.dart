import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';
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

  Map<String, dynamic> kindSpecific = {};
  Map<String, dynamic> kindSpecificFactoryValues = {};
  final Set<TextEditingController> createdControllers = {};
  List<SeriesRegistryEntry> seriesEntries = const [];
  Map<String, String?> customFieldValues;
  List<ItemImage> itemImages;
  LibraryCoverScanResult? coverScanPrefill;
  String? selectedSeriesId;

  void dispose() {
    for (final controller in createdControllers) {
      try {
        controller.dispose();
      } catch (_) {}
    }
    createdControllers.clear();
    kindSpecificFactoryValues = {};
  }

  void syncKindSpecificFactoryValues(CatalogMediaKind kind) {
    final factory = LibraryAddRegistry.manualKindSpecificFactoryFor(kind);
    if (factory == null) {
      if (kindSpecificFactoryValues.isNotEmpty || createdControllers.isNotEmpty) {
        dispose();
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
    return Map<String, dynamic>.from(baseValues)
      ..addAll(kindSpecificFactoryValues);
  }
}

