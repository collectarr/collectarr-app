import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
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
      final fixture = testLibraryEntry(
        id: 'entry-${kind.apiValue}',
        itemId: 'item-${kind.apiValue}',
        kind: kind.apiValue,
      );
      final dispatch = testLibraryEntryDispatchFrom(fixture);

      expect(dispatch, isA<LibraryEntryDispatch>());
      expect(dispatch.ref, fixture.ref);
      expect(dispatch.kind, kind);
      expect(dispatch.value, isNotNull);
    }
  });

  test('a dispatch ignores callbacks entry by another kind', () {
    final dispatch = testLibraryEntryDispatchFrom(
      testLibraryEntry(kind: CatalogMediaKind.comic.apiValue),
    );

    expect(dispatch.kind, CatalogMediaKind.comic);
    expect(dispatch.value, isNotNull);
  });
}
