import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late SmartListRepository repo;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repo = SmartListRepository(db);
  });

  tearDown(() => db.close());

  test('create and getAll round-trip advanced smart list criteria', () async {
    await repo.create(
      SmartList(
        id: 'ignored-global',
        name: 'Global queue',
        filterSelection: LibraryFilterSelection(
          trackingStatusFilter: LibraryTrackingStatusFilter.inProgress,
          loanStatusFilter: LibraryLoanStatusFilter.onLoan,
          dateRangeField: LibraryDateRangeField.finished,
          dateFrom: DateTime.utc(2026, 1, 10),
          dateTo: DateTime.utc(2026, 1, 20),
          customFieldDefinitionId: 'location',
          customFieldValue: 'Shelf A',
          location: 'Vault',
          tag: 'Signed',
          missingCover: true,
        ),
        quickView: LibraryQuickView.owned,
        sortRules: const [
          LibrarySortRule(
            column: LibrarySortColumn.updated,
            ascending: false,
          ),
          LibrarySortRule(
            column: LibrarySortColumn.title,
            ascending: true,
          ),
        ],
        searchQuery: 'dune',
      ),
    );
    await repo.create(
      const SmartList(
        id: 'ignored-books',
        name: 'Books only',
        mediaKind: 'book',
        filterSelection: LibraryFilterSelection(
          ownershipFilter: LibraryOwnershipFilter.owned,
        ),
      ),
    );
    await repo.create(
      const SmartList(
        id: 'ignored-games',
        name: 'Games only',
        mediaKind: 'game',
      ),
    );

    final bookLists = await repo.getAll(mediaKind: 'book');

    expect(bookLists.map((list) => list.name), ['Global queue', 'Books only']);

    final global = bookLists.first;
    expect(global.id, isNotEmpty);
    expect(global.mediaKind, isNull);
    expect(global.quickView, LibraryQuickView.owned);
    expect(global.sortColumn, LibrarySortColumn.updated);
    expect(global.sortAscending, isFalse);
    expect(global.sortRules, const [
      LibrarySortRule(
        column: LibrarySortColumn.updated,
        ascending: false,
      ),
      LibrarySortRule(
        column: LibrarySortColumn.title,
        ascending: true,
      ),
    ]);
    expect(global.searchQuery, 'dune');
    expect(
      global.filterSelection.trackingStatusFilter,
      LibraryTrackingStatusFilter.inProgress,
    );
    expect(
      global.filterSelection.loanStatusFilter,
      LibraryLoanStatusFilter.onLoan,
    );
    expect(
      global.filterSelection.dateRangeField,
      LibraryDateRangeField.finished,
    );
    expect(global.filterSelection.dateFrom, DateTime.utc(2026, 1, 10));
    expect(global.filterSelection.dateTo, DateTime.utc(2026, 1, 20));
    expect(global.filterSelection.customFieldDefinitionId, 'location');
    expect(global.filterSelection.customFieldValue, 'Shelf A');
    expect(global.filterSelection.location, 'Vault');
    expect(global.filterSelection.tag, 'Signed');
    expect(global.filterSelection.missingCover, isTrue);
  });

  test('update and delete persist changed criteria', () async {
    final created = await repo.create(
      const SmartList(
        id: 'ignored-book',
        name: 'Owned books',
        mediaKind: 'book',
        filterSelection: LibraryFilterSelection(
          ownershipFilter: LibraryOwnershipFilter.owned,
        ),
      ),
    );

    await repo.update(
      SmartList(
        id: created.id,
        name: 'Backlog books',
        mediaKind: 'book',
        filterSelection: const LibraryFilterSelection(
          trackingStatusFilter: LibraryTrackingStatusFilter.planned,
          customFieldDefinitionId: 'status',
          customFieldValue: 'Backlog',
          tag: 'Backlog',
        ),
        sortRules: const [
          LibrarySortRule(
            column: LibrarySortColumn.title,
            ascending: true,
          ),
          LibrarySortRule(
            column: LibrarySortColumn.updated,
            ascending: false,
          ),
        ],
        searchQuery: 'paperback',
      ),
    );

    final updated = await repo.getAll(mediaKind: 'book');
    expect(updated, hasLength(1));
    expect(updated.single.name, 'Backlog books');
    expect(
      updated.single.filterSelection.trackingStatusFilter,
      LibraryTrackingStatusFilter.planned,
    );
    expect(updated.single.filterSelection.customFieldDefinitionId, 'status');
    expect(updated.single.filterSelection.customFieldValue, 'Backlog');
    expect(updated.single.filterSelection.tag, 'Backlog');
    expect(updated.single.sortRules, const [
      LibrarySortRule(
        column: LibrarySortColumn.title,
        ascending: true,
      ),
      LibrarySortRule(
        column: LibrarySortColumn.updated,
        ascending: false,
      ),
    ]);
    expect(updated.single.searchQuery, 'paperback');

    await repo.delete(created.id);

    expect(await repo.getAll(mediaKind: 'book'), isEmpty);
  });
}