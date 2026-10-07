import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_import_data_page.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/reports/library_import_data_page.dart';

/// Navigates to the full Import Data view matching CLZ Web.
Future<void> importCollectionData({
  required BuildContext context,
  LibraryKindRegistration? type,
  String? initialSourceId,
  List<LibraryWorkspaceContext>? allShelfEntries,
}) async {
  final resolvedType = type ??
      defaultLibraryKindRegistry.require(CatalogMediaKind.music);

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LibraryImportDataPage(
        type: resolvedType,
        initialSourceId: initialSourceId,
        allShelfEntries: allShelfEntries,
      ),
    ),
  );
}
