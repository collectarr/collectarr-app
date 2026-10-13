import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/reports/library_export_csv_txt_page.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/reports/library_export_csv_txt_page.dart';

/// Navigates to the full Export to CSV / TXT view matching CLZ Web.
Future<void> exportCollectionCsvTxt({
  required BuildContext context,
  required String title,
  required List<LibraryProjectionView> items,
  required LibraryKindRegistration type,
  List<LibraryProjectionView>? allItems,
  Set<String>? selectedItemIds,
  List<LibraryWorkspaceContext>? allShelfEntries,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LibraryExportCsvTxtPage(
        type: type,
        items: items,
        allItems: allItems,
        selectedItemIds: selectedItemIds,
        allShelfEntries: allShelfEntries,
        initialTitle: title,
      ),
    ),
  );
}
