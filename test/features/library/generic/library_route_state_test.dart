import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/library_route_state.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library route state round-trips reproducible view params', () {
    final state = LibraryRouteState(
      kind: 'movie',
      searchQuery: 'alien',
      groupMode: 'movie.director',
      folderPreset: LibraryFolderPreset(
        modes: ['movie.director', 'movie.publisher'],
      ),
      selectedBucket: 'Action',
      selectedLetter: 'A',
      linkedMetadataValue: 'Ridley Scott',
      collectionStatusScope: LibraryCollectionStatusScope.inCollection,
      bucketCompletionScope: LibraryBucketCompletionScope.completed,
      quickView: LibraryQuickView.missingMetadata,
      filterSelection: LibraryFilterSelection(
        ownershipFilter: LibraryOwnershipFilter.owned,
        trackingStatusFilter: LibraryTrackingStatusFilter.completed,
        fieldValues: {'location': 'Shelf A'},
        missingMetadata: true,
      ),
      sortRules: [
        LibrarySortRule(column: 'title', ascending: true),
        LibrarySortRule(column: 'updated', ascending: false),
      ],
      isSidebarVisible: true,
    );

    final uri = state.toUri(Uri.parse('/libraries'), type: movieKindModule);
    final parsed = LibraryRouteState.fromUri(uri);

    expect(uri.queryParameters['kind'], 'movie');
    expect(uri.queryParameters['folder'],
        'group.movie.director>group.movie.publisher');
    expect(uri.queryParameters['filterValue'], 'Action');
    expect(uri.queryParameters['sort'], 'title:asc,updated:desc');
    expect(uri.queryParameters['bucketScope'], 'completed');
    expect(parsed.kind, 'movie');
    expect(parsed.searchQuery, 'alien');
    expect(parsed.groupMode, 'movie.director');
    expect(
      parsed.folderPreset,
      LibraryFolderPreset(
        modes: ['movie.director', 'movie.publisher'],
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
      parsed.bucketCompletionScope,
      LibraryBucketCompletionScope.completed,
    );
    expect(parsed.quickView, LibraryQuickView.missingMetadata);
    expect(
        parsed.filterSelection.ownershipFilter, LibraryOwnershipFilter.owned);
    expect(
      parsed.filterSelection.trackingStatusFilter,
      LibraryTrackingStatusFilter.completed,
    );
    expect(parsed.filterSelection.fieldValue('location'), 'Shelf A');
    expect(parsed.filterSelection.missingMetadata, isTrue);
    expect(parsed.sortRules, hasLength(2));
    expect(parsed.sortRules!.first.column, 'title');
    expect(parsed.sortRules!.first.ascending, isTrue);
    expect(parsed.sortRules!.last.column, 'updated');
    expect(parsed.sortRules!.last.ascending, isFalse);
    expect(parsed.isSidebarVisible, isTrue);
    expect(parsed.hasExplicitViewState, isTrue);
  });

  test('invalid route params fall back safely', () {
    final parsed = LibraryRouteState.fromUri(
      Uri.parse(
          '/libraries?kind=movie&folder=nope&sort=bad&filters=%%%&folders=maybe'),
    );

    expect(parsed.kind, 'movie');
    expect(parsed.groupMode, isNull);
    expect(parsed.folderPreset, isNull);
    expect(parsed.sortRules, isNull);
    expect(parsed.filterSelection, LibraryFilterSelection.none);
    expect(parsed.isSidebarVisible, isNull);
  });

  test('legacy sort params still decode', () {
    final parsed = LibraryRouteState.fromUri(
      Uri.parse('/libraries?kind=movie&sort=title.asc,updated.desc'),
    );

    expect(parsed.sortRules, hasLength(2));
    expect(parsed.sortRules!.first.column, 'title');
    expect(parsed.sortRules!.last.column, 'updated');
  });

  test('filtered route state drops explicit state when route kind mismatches',
      () {
    final state = LibraryRouteState(
      kind: 'movie',
      searchQuery: 'alien',
      quickView: LibraryQuickView.owned,
      filterSelection: const LibraryFilterSelection(
        ownershipFilter: LibraryOwnershipFilter.owned,
      ),
    );

    final filtered = state.filteredForType(musicKindModule);

    expect(filtered.kind, 'music');
    expect(filtered.hasExplicitViewState, isFalse);
    expect(filtered.searchQuery, isNull);
    expect(filtered.quickView, isNull);
    expect(filtered.filterSelection, LibraryFilterSelection.none);
  });

  test('filtered route state sanitizes grade-only views for no-grade types',
      () {
    final state = LibraryRouteState(
      kind: 'music',
      quickView: LibraryQuickView.missingGrade,
      filterSelection: const LibraryFilterSelection(
        fieldValues: {'grade': '9.8'},
      ),
    );

    final filtered = state.filteredForType(musicKindModule);

    expect(filtered.quickView, isNull);
    expect(
        filtered.filterSelection.ownershipFilter, LibraryOwnershipFilter.all);
    expect(filtered.filterSelection.fieldValue('grade'), isNull);

    final comicsFiltered = state.filteredForType(comicKindModule);
    expect(comicsFiltered.quickView, isNull);
    expect(comicsFiltered.filterSelection.ownershipFilter,
        LibraryOwnershipFilter.all);
  });

  test('filtered route state resets series scope outside series grouping', () {
    final state = LibraryRouteState(
      kind: 'book',
      groupMode: 'publisher',
      bucketCompletionScope: LibraryBucketCompletionScope.completed,
    );

    final filtered = state.filteredForType(bookKindModule);
    expect(filtered.groupMode, 'book.publisher');
    expect(filtered.bucketCompletionScope, LibraryBucketCompletionScope.all);

    final seriesFiltered = LibraryRouteState(
      kind: 'book',
      groupMode: 'series',
      bucketCompletionScope: LibraryBucketCompletionScope.completed,
    ).filteredForType(bookKindModule);
    expect(
      seriesFiltered.bucketCompletionScope,
      LibraryBucketCompletionScope.completed,
    );
  });
}
