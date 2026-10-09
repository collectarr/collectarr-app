import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_data_factories.dart';

void main() {
  test(
      'collection membership scopes search, sidebar buckets and totals by entry identity',
      () {
    final type = defaultLibraryKindRegistry.require(CatalogMediaKind.music);
    final shelf = ShelfState(
      entries: [
        for (final id in ['a', 'b'])
          testLibraryWorkspaceSource(
            itemId: 'catalog-$id',
            kind: 'music',
            title: 'Album $id',
            libraryEntrySummary: testLibraryEntrySummary(testLibraryEntry(
                id: 'entry-$id',
                itemId: 'catalog-$id',
                kind: 'music',
                catalogTitle: 'Album $id')),
            catalogData: MusicWorkspaceData.fromMusic(MusicAlbum(
              id: CatalogItemRef(
                  kind: CatalogMediaKind.music, id: 'catalog-$id'),
              title: 'Album $id',
              artist: 'Artist $id',
            )),
          ),
      ],
      entryCount: 2,
      wishlistCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );
    LibraryProjection project(Set<String> members, {String search = ''}) =>
        LibraryProjectionEngine().execute(
          shelf: shelf,
          type: type,
          viewState: libraryViewProfileForKind(type.kind).defaults(),
          query: LibraryProjectionQuery(
              collectionEntryIds: members, searchQuery: search),
        );
    final selected = project({'entry-a'});
    expect(selected.allItems.map((i) => i.target.id), ['catalog-a']);
    expect(selected.filteredItems, hasLength(1));
    expect(selected.buckets.any((b) => b.title == 'Artist b'), isFalse);
    expect(project({'entry-a'}, search: 'Album b').filteredItems, isEmpty);
    expect(project({}).allItems, isEmpty);
    expect(
        project({'entry-b'}).filteredItems.single.dto.primaryLabel, 'Album b');
  });
}
