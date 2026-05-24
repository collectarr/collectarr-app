import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('smart lists dialog shows advanced filter chips and loads saved view', (
    tester,
  ) async {
    final repo = SmartListRepository(db);
    await repo.create(
      SmartList(
        id: '',
        name: 'Backlog sci-fi',
        mediaKind: 'book',
        filterSelection: LibraryFilterSelection(
          trackingStatusFilter: LibraryTrackingStatusFilter.inProgress,
          loanStatusFilter: LibraryLoanStatusFilter.available,
          dateRangeField: LibraryDateRangeField.finished,
          dateFrom: DateTime.utc(2026, 1, 1),
          dateTo: DateTime.utc(2026, 1, 31),
          customFieldDefinitionId: 'cf-location',
          customFieldValue: 'Shelf A',
        ),
        quickView: LibraryQuickView.owned,
        sortColumn: LibrarySortColumn.updated,
        sortAscending: false,
        searchQuery: 'dune',
      ),
    );

    SmartListLoadResult? loaded;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                loaded = await showSmartListsDialog(
                  context: context,
                  db: db,
                  mediaKind: 'book',
                  currentFilter: LibraryFilterSelection.none,
                  customFieldDefinitions: [
                    CustomFieldDefinition(
                      id: 'cf-location',
                      name: 'Location',
                      fieldType: 'select',
                      createdAt: DateTime.utc(2026, 1, 1),
                    ),
                  ],
                );
              },
              child: const Text('Open smart lists'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open smart lists'));
    await tester.pumpAndSettle();

    expect(find.text('Backlog sci-fi'), findsWidgets);
    expect(find.text('Quick view: Owned'), findsOneWidget);
    expect(find.text('Sort: updated desc'), findsOneWidget);
    expect(find.text('Search: dune'), findsOneWidget);
    expect(find.text('Kind: book'), findsOneWidget);
    expect(find.text('Tracking: In progress'), findsOneWidget);
    expect(find.text('Loan: Available locally'), findsOneWidget);
    expect(find.text('Date: Finished 2026-01-01-2026-01-31'), findsOneWidget);
    expect(find.text('Custom: Location = Shelf A'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Load'));
    await tester.pumpAndSettle();

    expect(loaded, isNotNull);
    expect(
      loaded!.filterSelection.trackingStatusFilter,
      LibraryTrackingStatusFilter.inProgress,
    );
    expect(loaded!.filterSelection.customFieldDefinitionId, 'cf-location');
    expect(loaded!.filterSelection.customFieldValue, 'Shelf A');
    expect(loaded!.quickView, LibraryQuickView.owned);
    expect(loaded!.sortColumn, LibrarySortColumn.updated);
    expect(loaded!.sortAscending, isFalse);
    expect(loaded!.searchQuery, 'dune');
  });
}