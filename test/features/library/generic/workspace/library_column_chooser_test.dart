import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const availableColumns = [
    'title',
    'issue',
    'publisher',
    'release_date',
    'barcode',
  ];

  String labelFor(Object column) {
    if (column is! String) return column.toString();
    return switch (column) {
      'title' => 'Series',
      'issue' => 'Issue',
      'publisher' => 'Publisher',
      'release_date' => 'Release Date',
      'barcode' => 'Barcode',
      _ => column as String,
    };
  }

  LibraryTableColumnGroup groupFor(Object column) {
    if (column is! String) return LibraryTableColumnGroup.main;
    return switch (column) {
      'barcode' || 'release_date' =>
        LibraryTableColumnGroup.edition,
      'publisher' => LibraryTableColumnGroup.main,
      _ => LibraryTableColumnGroup.main,
    };
  }

  testWidgets('column chooser renders the CLZ-style manager shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryColumnChooserDialog(
            accent: Colors.cyan,
            availableColumns: availableColumns,
            selectedColumns: const {
              'title',
              'issue',
              'publisher',
            },
            defaultColumns: const {
              'title',
              'issue',
            },
            columnLabel: labelFor,
            columnGroup: groupFor,
            presets: const [
              LibraryTableColumnPreset(
                label: 'Essential',
                columns: {
                  'title',
                  'issue',
                },
              ),
            ],
            savedPresets: const [
              LibraryTableColumnPreset(
                id: 'full-preset',
                label: 'Full View',
                columns: {
                  'title',
                  'issue',
                  'publisher',
                  'release_date',
                },
              ),
            ],
            pinnedFavoriteKeys: const {
              'saved:full-preset',
            },
            onSavePreset: null,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Select Column Fields'), findsOneWidget);
    expect(find.text('Column Favorites'), findsOneWidget);
    expect(find.text('Available fields'), findsOneWidget);
    expect(find.text('Selected columns'), findsOneWidget);
    expect(find.byKey(const ValueKey('column-preset-Full View')), findsOneWidget);
    // Pin icons are no longer shown in the compact CLZ-style shelf.
    expect(find.byKey(const ValueKey('selected-column-title')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('selected-column-issue')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const ValueKey('selected-column-issue')), findsOneWidget);
  });

  testWidgets('tapping a preset replaces the selected column list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryColumnChooserDialog(
            accent: Colors.cyan,
            availableColumns: availableColumns,
            selectedColumns: const {
              'title',
              'issue',
            },
            defaultColumns: const {
              'title',
              'issue',
            },
            columnLabel: labelFor,
            columnGroup: groupFor,
            presets: const [
              LibraryTableColumnPreset(
                label: 'Barcode View',
                columns: {
                  'title',
                  'barcode',
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('selected-column-issue')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const ValueKey('selected-column-issue')), findsOneWidget);
    expect(find.byKey(const ValueKey('selected-column-barcode')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('column-preset-Barcode View')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('selected-column-issue')), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('selected-column-barcode')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const ValueKey('selected-column-barcode')), findsOneWidget);
  });

  testWidgets('pinned favorite toggle callback is accepted by dialog', (
    tester,
  ) async {
    LibraryTableColumnPreset? toggledPreset;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryColumnChooserDialog(
            accent: Colors.cyan,
            availableColumns: availableColumns,
            selectedColumns: const {
              'title',
              'issue',
            },
            defaultColumns: const {
              'title',
              'issue',
            },
            columnLabel: labelFor,
            presets: const [
              LibraryTableColumnPreset(
                label: 'Barcode View',
                columns: {
                  'title',
                  'barcode',
                },
              ),
            ],
            pinnedFavoriteKeys: const {},
            onTogglePinnedFavorite: (preset) => toggledPreset = preset,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The compact CLZ-style shelf no longer exposes pin buttons directly;
    // verify the dialog renders without error when the callback is provided.
    expect(find.text('Column Favorites'), findsOneWidget);
    expect(toggledPreset, isNull);
    expect(libraryColumnFavoriteKey(
      const LibraryTableColumnPreset(
        label: 'Barcode View',
        columns: {'title', 'barcode'},
      ),
    ), 'builtin:barcode_view');
  });
}