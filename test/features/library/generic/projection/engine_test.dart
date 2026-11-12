import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/presentation/alphabet_field.dart';
import 'package:collectarr_app/features/library/config/search_target.dart';
import 'package:collectarr_app/features/library/generic/filters.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/projection_provider.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  final type = defaultLibraryKindRegistry.require(CatalogMediaKind.music);
  final fields = libraryKindWorkspaceForKind(type.kind).fields;

  ShelfState shelfOf(List<(String id, String title, String artist)> albums) =>
      ShelfState(
        entries: [
          for (final (id, title, artist) in albums)
            testLibraryWorkspaceSource(
              itemId: id,
              kind: 'music',
              title: title,
              catalogData: MusicWorkspaceData.fromMusic(MusicAlbum(
                id: CatalogItemRef(kind: CatalogMediaKind.music, id: id),
                title: title,
                artist: artist,
              )),
            ),
        ],
        entryCount: 0,
        wishlistCount: 0,
        pricedCount: 0,
        totalPaidCents: null,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      );

  LibrarySortRuleRuntime rule(String sortId, {required bool ascending}) =>
      LibrarySortRuleRuntime(
        sortId: fields.decodeSortId(sortId),
        ascending: ascending,
      );

  List<String> shownIds(LibraryProjection projection) =>
      [for (final item in projection.filteredItems) item.target.id];

  final shelf = shelfOf([
    ('zebra', 'Zebra', 'The Beatles'),
    ('apple', 'Apple', 'The Beatles'),
    ('mango', 'Mango', 'ABBA'),
  ]);

  test('sorts by each rule in turn and reverses a descending rule', () {
    List<String> sorted(List<LibrarySortRuleRuntime> sortRules) =>
        shownIds(LibraryProjectionEngine().execute(
          shelf: shelf,
          type: type,
          sortRules: sortRules,
          query: const LibraryProjectionQuery(),
        ));
    final artist = MusicCatalogWorkspaceFields.artistSummary.id.value;
    final title = MusicCatalogWorkspaceFields.title.id.value;

    expect(
      sorted([rule(artist, ascending: true), rule(title, ascending: true)]),
      ['mango', 'apple', 'zebra'],
    );
    expect(
      sorted([rule(artist, ascending: true), rule(title, ascending: false)]),
      ['mango', 'zebra', 'apple'],
    );
    expect(
      sorted([rule(artist, ascending: false), rule(title, ascending: true)]),
      ['apple', 'zebra', 'mango'],
    );
  });

  test('items the rules do not tell apart are ordered by their label', () {
    final projection = LibraryProjectionEngine().execute(
      shelf: shelf,
      type: type,
      sortRules: const [],
      query: const LibraryProjectionQuery(),
    );

    expect(shownIds(projection), ['apple', 'mango', 'zebra']);
  });

  test('a blank search shows every item and a search narrows them', () {
    List<String> search(String query) =>
        shownIds(LibraryProjectionEngine().execute(
          shelf: shelf,
          type: type,
          sortRules: const [],
          query: LibraryProjectionQuery(searchQuery: query),
        ));

    expect(search('   '), ['apple', 'mango', 'zebra']);
    expect(search('abba'), ['mango']);
    expect(search('matches:^z'), ['zebra']);
  });

  test('selecting another item reuses the sorted and grouped library',
      () async {
    final container = ProviderContainer(overrides: [
      pickListSortNamesProvider(type.kind.apiValue)
          .overrideWith((ref) => Stream.value(const {})),
    ]);
    addTearDown(container.dispose);
    LibraryProjectionRequest request(String? selectedItemId) =>
        LibraryProjectionRequest(
          shelf: shelf,
          type: type,
          sortRules: const [],
          query: '',
          linkedMetadataFilters: const [],
          selectedLetter: null,
          alphabetField: LibraryAlphabetField.title,
          selectedBucket: null,
          selectedItemId: selectedItemId,
          quickView: null,
          collectionStatusScope: LibraryCollectionStatusScope.all,
          groupMode: fields.defaultGroup!.value,
          bucketScopeFilters: const [],
          overrideBuckets: null,
          constrainedItemIds: null,
          filterSelection: LibraryFilterSelection.none,
          customFieldValuesByItem: const {},
          customFieldValuesByDefinitionByItem: const {},
          activeLoanLibraryEntryIds: const {},
          searchTarget: LibrarySearchTarget.all,
        );

    final unselected =
        container.listen(libraryProjectionProvider(request(null)), (_, __) {});
    final mango = container.listen(
        libraryProjectionProvider(request('mango')), (_, __) {});
    final zebra = container.listen(
        libraryProjectionProvider(request('zebra')), (_, __) {});

    expect(unselected.read().selectedItem, isNull);
    expect(mango.read().selectedItem?.target.id, 'mango');
    expect(zebra.read().selectedItem?.target.id, 'zebra');
    expect(mango.read().filteredItems, same(unselected.read().filteredItems));
    expect(zebra.read().buckets, same(unselected.read().buckets));
    expect(
      container
          .read(libraryProjectionProvider(request('missing')))
          .selectedItem,
      isNull,
    );
  });
}
