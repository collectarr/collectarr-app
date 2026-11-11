import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/contracts/local_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/models.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';

/// Change bookkeeping shared by catalog editors. Kinds still build their own
/// catalog data, tracking selections and Core correction field maps.
final class LibraryCatalogEditChanges {
  LibraryCatalogEditChanges({
    required Map<String, Object?> initialCatalogFields,
    required Iterable<CustomFieldValue> customFieldValues,
  }) : _initialCatalogFields = _snapshot(initialCatalogFields) {
    _customFields = {
      for (final value in customFieldValues)
        value.fieldDefinitionId: value.value,
    };
    _initialCustomFields = Map.of(_customFields);
  }

  final String _initialCatalogFields;
  late final Map<String, String?> _initialCustomFields;
  late Map<String, String?> _customFields;
  List<ItemImageEdit> _images = const [];
  List<ItemImageEdit> _covers = const [];

  Map<String, String?> get customFields => Map.unmodifiable(_customFields);

  set customFields(Map<String, String?> values) =>
      _customFields = Map.of(values);
  set images(List<ItemImageEdit> edits) => _images = List.unmodifiable(edits);
  set covers(List<ItemImageEdit> edits) => _covers = List.unmodifiable(edits);

  bool hasChanges(Map<String, Object?> catalogFields) =>
      _initialCatalogFields != _snapshot(catalogFields) ||
      !mapEquals(_initialCustomFields, _customFields) ||
      _images.isNotEmpty ||
      _covers.isNotEmpty;

  LibraryEditSelection selection({
    required CatalogSearchCandidate kindItem,
    LibraryTrackingEditSelection? tracking,
    List<LibraryLocalEditChange> localChanges = const [],
  }) =>
      LibraryEditSelection(
        kindItem: kindItem,
        tracking: tracking,
        localChanges: List.unmodifiable(localChanges),
        customFieldEdits: customFields,
        itemImageEdits: List.unmodifiable([..._images, ..._covers]),
      );
}

String _snapshot(Map<String, Object?> fields) => jsonEncode(_ordered(fields));

Object? _ordered(Object? value) => switch (value) {
      Map<String, dynamic>() => {
          for (final key in value.keys.toList()..sort())
            key: _ordered(value[key]),
        },
      List() => value.map(_ordered).toList(),
      _ => value,
    };
