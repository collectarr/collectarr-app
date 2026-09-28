import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/library/actions/import_export_actions.dart';
import 'package:collectarr_app/features/library/data/catalog_item_v1_workspace_repository.dart';
import 'package:collectarr_app/features/library/domain/catalog_item_v1_schema.dart';
import 'package:flutter/material.dart';

/// Exports one row per Owned Copy using the pinned Catalog Item v1 contract.
/// Repeated catalog children and copy kind details remain JSON cells so the
/// file preserves their typed structure without introducing another schema.
final class CatalogItemV1CsvExporter {
  const CatalogItemV1CsvExporter();

  ExportPreviewArtifact export(Iterable<CatalogItemV1WorkspaceItem> source) {
    final items = source.toList(growable: false);
    final catalogFields = <String>{};
    for (final kind
        in CatalogMediaKind.values.where((kind) => !kind.isUnknown)) {
      final properties = catalogItemV1WriteSchemaForKind(kind)['properties'];
      if (properties is! Map<String, dynamic>) continue;
      for (final entry in properties.entries) {
        if (entry.key == 'kind') continue;
        catalogFields.add(entry.key);
      }
    }

    final orderedCopyFields = <String>[];
    final seenCopyFields = <String>{};
    final copyKindFields = <String>{};
    for (final item in items) {
      for (final copy in item.copies) {
        for (final key in copy.toJson().keys) {
          if (key == 'catalog_item' ||
              key == 'kind_details' ||
              !seenCopyFields.add(key)) {
            continue;
          }
          orderedCopyFields.add(key);
        }
        copyKindFields.addAll(copy.kindDetails.toJson().keys);
      }
    }
    final orderedKindFields = copyKindFields.toList()..sort();
    final header = <String>[
      'catalog_item_id',
      'kind',
      'schema_version',
      for (final key in catalogFields) 'catalog.$key',
      for (final key in orderedCopyFields) 'copy.$key',
      for (final key in orderedKindFields) 'copy.details.$key',
    ];
    final rows = <List<Object?>>[
      header,
      for (final item in items)
        for (final copy in item.copies)
          [
            item.reference.id,
            item.reference.kind.apiValue,
            '1',
            for (final key in catalogFields)
              _csvCell(item.catalogItem?.details.toJson()[key]),
            for (final key in orderedCopyFields) _csvCell(copy.toJson()[key]),
            for (final key in orderedKindFields)
              _csvCell(copy.kindDetails.toJson()[key]),
          ],
    ];
    return ExportPreviewArtifact(
      id: 'catalog_item_v1.csv',
      label: 'Catalog Item v1 CSV',
      icon: Icons.library_books_outlined,
      filename: 'collectarr-catalog-items-v1.csv',
      mimeType: 'text/csv',
      content: const CsvWriter().write(rows),
    );
  }
}

Object _csvCell(Object? value) {
  if (value == null) return '';
  if (value is Map || value is List) return jsonEncode(value);
  return value.toString();
}
