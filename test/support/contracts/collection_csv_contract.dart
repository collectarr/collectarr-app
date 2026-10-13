import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:flutter_test/flutter_test.dart';

import '../builders/catalog_item_builder.dart';
import '../builders/library_entry_builder.dart';
import '../builders/workspace_item_builder.dart';

LibraryWorkspaceContext collectionCsvFixture({
  required CatalogItemDto catalog,
  TestLibraryEntry? personal,
  DateTime? updatedAt,
}) {
  final entry = personal ?? testLibraryEntry(
    id: 'entry-1', itemId: catalog.id, kind: catalog.kind,
    catalogTitle: catalog.kindData['title'] as String,
    updatedAt: updatedAt ?? DateTime.utc(2026, 5, 15),
  );
  if (entry.catalogRef != catalog.catalogItemRef) {
    throw ArgumentError('CSV fixture catalog and entry must share kind and Core identity.');
  }
  return testLibraryWorkspaceSource(
    itemId: catalog.id, kind: catalog.kind, catalogItem: catalog,
    catalogData: testWorkspaceCatalogData(catalog), libraryEntry: entry,
  );
}

void verifyCollectionCsvCatalogContract({
  required CollectionCsvKindProfile projection,
  required LibraryWorkspaceContext fixture,
  required List<String> expectedCells,
}) {
  expect(fixture.item.kind, projection.kind, reason: 'CSV kind ownership');
  expect(projection.catalogCells(fixture), expectedCells);
}
