import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_shelf_projection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projection request equality keys by shelf identity query and filters',
      () {
    final state = _shelfState();
    final left = ComicsShelfProjectionRequest(
      state: state,
      query: 'batman',
      filters: const ComicsFilterSelection(
        ownershipFilter: ComicsOwnershipFilter.owned,
      ),
    );
    final right = ComicsShelfProjectionRequest(
      state: state,
      query: 'batman',
      filters: const ComicsFilterSelection(
        ownershipFilter: ComicsOwnershipFilter.owned,
      ),
    );

    expect(left, right);
    expect(left.hashCode, right.hashCode);
  });

  test('projection provider filters shelf entries', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final projection = container.read(
      comicsShelfProjectionProvider(
        ComicsShelfProjectionRequest(
          state: _shelfState(),
          query: 'batman',
          filters: ComicsFilterSelection.none,
        ),
      ),
    );

    expect(projection.entries.single.itemId, 'comic-1');
    expect(projection.items.single.title, 'Batman');
  });
}

ShelfState _shelfState() {
  return ShelfState(
    entries: [
      const ShelfEntry(
        itemId: 'comic-1',
        catalogItem: CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Batman',
        ),
      ),
      const ShelfEntry(
        itemId: 'comic-2',
        catalogItem: CatalogItem(
          id: 'comic-2',
          kind: 'comic',
          title: 'Superman',
        ),
      ),
    ],
    ownedCount: 0,
    wishlistCount: 0,
    missingGradeCount: 0,
    pricedCount: 0,
    totalPaidCents: null,
    primaryCurrency: null,
    hasMixedCurrencies: false,
  );
}
