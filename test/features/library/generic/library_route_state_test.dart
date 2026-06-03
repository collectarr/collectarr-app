import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/library_route_state.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library route state round-trips reproducible view params', () {
    final state = LibraryRouteState(
      kind: 'movie',
      searchQuery: 'alien',
      groupMode: LibraryGroupMode.genre,
      folderPreset: LibraryFolderPreset(
        modes: [LibraryGroupMode.genre, LibraryGroupMode.releaseYear],
      ),
      selectedBucket: 'Action',
      selectedLetter: 'A',
      linkedMetadataValue: 'Ridley Scott',
      collectionStatusScope: LibraryCollectionStatusScope.inCollection,
      seriesCompletionScope: LibrarySeriesCompletionScope.completed,
      quickView: LibraryQuickView.missingMetadata,
      filterSelection: LibraryFilterSelection(
        ownershipFilter: LibraryOwnershipFilter.owned,
        trackingStatusFilter: LibraryTrackingStatusFilter.completed,
        location: 'Shelf A',
        missingMetadata: true,
      ),
      sortRules: [
        LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
        LibrarySortRule(column: LibrarySortColumn.updated, ascending: false),
      ],
      isSidebarVisible: true,
    );

    final uri = state.toUri(Uri.parse('/libraries'), kind: 'movie');
    final parsed = LibraryRouteState.fromUri(uri);

    expect(uri.queryParameters['kind'], 'movie');
    expect(uri.queryParameters['folder'], 'genre>releaseYear');
    expect(uri.queryParameters['filterValue'], 'Action');
    expect(uri.queryParameters['sort'], 'title.asc,updated.desc');
    expect(uri.queryParameters['seriesScope'], 'completed');
    expect(parsed.kind, 'movie');
    expect(parsed.searchQuery, 'alien');
    expect(parsed.groupMode, LibraryGroupMode.genre);
    expect(
      parsed.folderPreset,
      LibraryFolderPreset(
        modes: [LibraryGroupMode.genre, LibraryGroupMode.releaseYear],
      ),
    );
    expect(parsed.selectedBucket, 'Action');
    expect(parsed.selectedLetter, 'A');
    expect(parsed.linkedMetadataValue, 'Ridley Scott');
    expect(
      parsed.collectionStatusScope,
      LibraryCollectionStatusScope.inCollection,
    );
    expect(
      parsed.seriesCompletionScope,
      LibrarySeriesCompletionScope.completed,
    );
    expect(parsed.quickView, LibraryQuickView.missingMetadata);
    expect(parsed.filterSelection.ownershipFilter, LibraryOwnershipFilter.owned);
    expect(
      parsed.filterSelection.trackingStatusFilter,
      LibraryTrackingStatusFilter.completed,
    );
    expect(parsed.filterSelection.location, 'Shelf A');
    expect(parsed.filterSelection.missingMetadata, isTrue);
    expect(parsed.sortRules, hasLength(2));
    expect(parsed.sortRules!.first.column, LibrarySortColumn.title);
    expect(parsed.sortRules!.first.ascending, isTrue);
    expect(parsed.sortRules!.last.column, LibrarySortColumn.updated);
    expect(parsed.sortRules!.last.ascending, isFalse);
    expect(parsed.isSidebarVisible, isTrue);
    expect(parsed.hasExplicitViewState, isTrue);
  });

  test('invalid route params fall back safely', () {
    final parsed = LibraryRouteState.fromUri(
      Uri.parse('/libraries?kind=movie&folder=nope&sort=bad&filters=%%%&folders=maybe'),
    );

    expect(parsed.kind, 'movie');
    expect(parsed.groupMode, isNull);
    expect(parsed.folderPreset, isNull);
    expect(parsed.sortRules, isNull);
    expect(parsed.filterSelection, LibraryFilterSelection.none);
    expect(parsed.isSidebarVisible, isNull);
  });
}