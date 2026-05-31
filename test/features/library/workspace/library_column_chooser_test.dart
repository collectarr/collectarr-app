import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String labelFor(LibraryTableColumn column) => switch (column) {
        LibraryTableColumn.title => 'Series',
        LibraryTableColumn.issue => 'Issue',
        LibraryTableColumn.publisher => 'Publisher',
        LibraryTableColumn.releaseDate => 'Release Date',
        LibraryTableColumn.barcode => 'Barcode',
        _ => column.name,
      };

  LibraryTableColumnGroup groupFor(LibraryTableColumn column) => switch (column) {
        LibraryTableColumn.barcode || LibraryTableColumn.releaseDate =>
          LibraryTableColumnGroup.edition,
        LibraryTableColumn.publisher => LibraryTableColumnGroup.main,
        _ => LibraryTableColumnGroup.main,
      };

  testWidgets('column chooser renders the CLZ-style manager shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryColumnChooserDialog(
            accent: Colors.cyan,
            selectedColumns: const {
              LibraryTableColumn.title,
              LibraryTableColumn.issue,
              LibraryTableColumn.publisher,
            },
            defaultColumns: const {
              LibraryTableColumn.title,
              LibraryTableColumn.issue,
            },
            columnLabel: labelFor,
            columnGroup: groupFor,
            presets: const [
              LibraryTableColumnPreset(
                label: 'Essential',
                columns: {
                  LibraryTableColumn.title,
                  LibraryTableColumn.issue,
                },
              ),
            ],
            savedPresets: const [
              LibraryTableColumnPreset(
                id: 'full-preset',
                label: 'Full View',
                columns: {
                  LibraryTableColumn.title,
                  LibraryTableColumn.issue,
                  LibraryTableColumn.publisher,
                  LibraryTableColumn.releaseDate,
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
            selectedColumns: const {
              LibraryTableColumn.title,
              LibraryTableColumn.issue,
            },
            defaultColumns: const {
              LibraryTableColumn.title,
              LibraryTableColumn.issue,
            },
            columnLabel: labelFor,
            columnGroup: groupFor,
            presets: const [
              LibraryTableColumnPreset(
                label: 'Barcode View',
                columns: {
                  LibraryTableColumn.title,
                  LibraryTableColumn.barcode,
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
            selectedColumns: const {
              LibraryTableColumn.title,
              LibraryTableColumn.issue,
            },
            defaultColumns: const {
              LibraryTableColumn.title,
              LibraryTableColumn.issue,
            },
            columnLabel: labelFor,
            presets: const [
              LibraryTableColumnPreset(
                label: 'Barcode View',
                columns: {
                  LibraryTableColumn.title,
                  LibraryTableColumn.barcode,
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
        columns: {LibraryTableColumn.title, LibraryTableColumn.barcode},
      ),
    ), 'builtin:barcode_view');
  });
}