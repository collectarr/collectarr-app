import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_export_csv_txt_page.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/reports/library_export_csv_txt_page.dart';

/// Navigates to the full Export to CSV / TXT view matching CLZ Web.
Future<void> exportCollectionCsvTxt({
  required BuildContext context,
  required String title,
  required List<LibraryProjectionView> items,
  LibraryKindRegistration? type,
  List<LibraryProjectionView>? allItems,
  Set<String>? selectedItemIds,
  List<LibraryWorkspaceContext>? allShelfEntries,
}) async {
  final resolvedType = type ??
      (items.isNotEmpty
          ? defaultLibraryKindRegistry.require(items.first.source.mediaKind)
          : defaultLibraryKindRegistry.require(CatalogMediaKind.music));

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LibraryExportCsvTxtPage(
        type: resolvedType,
        items: items,
        allItems: allItems,
        selectedItemIds: selectedItemIds,
        allShelfEntries: allShelfEntries,
        initialTitle: title,
      ),
    ),
  );
}
