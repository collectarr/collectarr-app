import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workspace config exposes a column registry bridge', () {
    const registry = LibraryColumnRegistry([
      LibraryColumnDefinition(
        id: 'title',
        label: 'Title',
        scope: LibraryColumnScope.work,
        kinds: {CatalogMediaKind.book},
      ),
    ]);

    final config = LibraryWorkspaceConfig(
      kind: CatalogMediaKind.book,
      title: 'Books',
      icon: Icons.book,
      accent: Colors.blue,
      preferencePrefix: 'books',
      defaultSortColumn: LibrarySortColumn.title,
      defaultVisibleColumns: {},
      columnRegistry: registry,
    );

    expect(config.columnRegistry.definitions, hasLength(1));
    expect(config.columnRegistry.byId('title')?.label, 'Title');
  });
}
