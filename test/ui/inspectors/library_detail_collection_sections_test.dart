import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_data_factories.dart';

void main() {
  testWidgets('detail personal section shows value tracking fields', (
    tester,
  ) async {
    final owned1 = testOwnedItem(
      id: 'owned-1',
      itemId: 'movie-1',
      purchaseDate: DateTime.utc(2026, 5, 11),
      pricePaidCents: 1299,
      coverPriceCents: 1599,
      sellPriceCents: 1899,
      soldTo: 'Local shop',
      currency: 'USD',
      updatedAt: DateTime.utc(2026, 5, 22),
    );
    final source = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Blade Runner 2049',
      ),
      ownedItem: owned1,
    );
    const node = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final movieItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryDetailPersonalSection(
            item: movieItem,
            ownedItem: owned1,
            ownedCopies: [
              testOwnedItem(
                id: 'owned-1',
                itemId: 'movie-1',
                purchaseDate: DateTime.utc(2026, 5, 11),
                pricePaidCents: 1299,
                marketValueCents: 1599,
                coverPriceCents: 1599,
                sellPriceCents: 1899,
                soldTo: 'Local shop',
                currency: 'USD',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              testOwnedItem(
                id: 'owned-2',
                itemId: 'movie-1',
                pricePaidCents: 999,
                marketValueCents: 2499,
                currency: 'USD',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
            ],
            accent: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.text('Local collection'), findsOneWidget);
  });
}
