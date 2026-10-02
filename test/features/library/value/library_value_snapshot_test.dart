import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/value/library_value_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  test('combines manual, purchase, sold, and insurance values', () {
    final collectionItem = testCollectionItem(
      id: 'owned-1',
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId('collection_item'),
        id: 'comic-1',
      ),
      updatedAt: DateTime.utc(2026, 7, 5),
      pricePaidCents: 1200,
      sellPriceCents: 3200,
      marketValueCents: 1800,
      currency: 'USD',
    );
    final source = LibraryWorkspaceSource(
      itemId: 'comic-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Sample Comic',
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 2500,
        ),
      ).asShelfCatalogItem),
      collectionItemSummary: testCollectionItemSummary(collectionItem),
    );
    const node = LibraryCatalogItemNodeRef(catalogItemId: 'comic-1');
    final dto = const ComicWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    final snapshot = LibraryValueSnapshot.fromItem(
      item,
      purchasePriceCents: collectionItem.pricePaidCents,
      soldPriceCents: collectionItem.sellPriceCents,
      manualEstimatedValueCents: collectionItem.marketValueCents,
      ownedCurrency: collectionItem.currency,
    );

    expect(snapshot.manualEstimatedValueCents, 1800);
    expect(snapshot.displayPrimaryValueCents, 1800);
    expect(snapshot.insuranceValueCents, 1800);
    expect(snapshot.unrealizedGainLossCents, 600);
    expect(snapshot.historyEntries.map((entry) => entry.label), [
      'Purchase price',
      'Manual estimate',
      'Sold price',
    ]);
  });
}
