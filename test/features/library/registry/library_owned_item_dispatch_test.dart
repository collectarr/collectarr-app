import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispatch exposes exactly the owning concrete callback', () {
    const kinds = <CatalogMediaKind>[
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.manga,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    ];

    for (final kind in kinds) {
      final fixture = testOwnedItem(
        id: 'owned-${kind.apiValue}',
        itemId: 'item-${kind.apiValue}',
        kind: kind.apiValue,
      );
      final dispatch = testOwnedItemDispatchFrom(fixture);

      expect(dispatch, isA<LibraryOwnedItemDispatch>());
      expect(dispatch.ref, fixture.ref);
      expect(
        dispatch.map<String>(
          anime: (_) => 'anime',
          boardgame: (_) => 'boardgame',
          book: (_) => 'book',
          comic: (_) => 'comic',
          game: (_) => 'game',
          manga: (_) => 'manga',
          movie: (_) => 'movie',
          music: (_) => 'music',
          tv: (_) => 'tv',
        ),
        kind.apiValue,
      );
    }
  });

  test('a dispatch ignores callbacks owned by another kind', () {
    final dispatch = testOwnedItemDispatchFrom(
      testOwnedItem(kind: CatalogMediaKind.comic.apiValue),
    );

    expect(dispatch.map<String>(book: (_) => 'book'), isNull);
    expect(dispatch.map<String>(comic: (_) => 'comic'), 'comic');
  });
}
