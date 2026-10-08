import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/reports/library_import_data_page.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/reports/library_import_data_page.dart';

/// Navigates to the full Import Data view matching CLZ Web.
Future<void> importCollectionData({
  required BuildContext context,
  required LibraryKindRegistration type,
  String? initialSourceId,
  List<LibraryWorkspaceContext>? allShelfEntries,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LibraryImportDataPage(
        type: type,
        initialSourceId: initialSourceId,
        allShelfEntries: allShelfEntries,
      ),
    ),
  );
}
