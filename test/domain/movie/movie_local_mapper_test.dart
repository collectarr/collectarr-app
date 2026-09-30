import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_owned_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete Movie owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MovieOwnedItem(
      id: const MovieOwnedCopyId('owned-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId('work'),
        id: 'movie-1',
      ),
      createdAt: DateTime.utc(2026, 1, 2),
      isDigital: false,
      targetRef: const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId('release'),
        id: 'variant-1',
        parentId: 'release-1',
      ),
      condition: 'Near Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 1, 3),
      pricePaidCents: 2499,
      currency: 'USD',
      personalNotes: 'Collector copy',
      quantity: 2,
      indexNumber: 1,
      tags: 'favorite,4k',
      updatedAt: DateTime.utc(2026, 1, 4),
      soldAt: DateTime.utc(2026, 2, 1),
      sellPriceCents: 2999,
      soldTo: 'buyer@example.com',
      ownerUserId: 'user-1',
      ownerLabel: 'Collector',
      locationId: 'shelf-1',
      purchaseStore: 'Local shop',
      collectionStatus: 'owned',
      marketValueCents: 3500,
      details: const MovieOwnedDetails(
        features: 'Director commentary',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        boxSetId: 'box-1',
        boxSetName: 'The Matrix Collection',
        region: 'A',
        packaging: 'SteelBook',
        distributor: 'Warner Home Video',
      ),
    );

    await db.into(db.movieOwnedItemsRows).insert(
          MovieOwnedLocalMapper.toRow(item),
        );
    final row = await db.select(db.movieOwnedItemsRows).getSingle();
    final restored = MovieOwnedLocalMapper.fromRow(row);

    expect(row.targetRefJson, isNotNull);
    expect(restored.id, item.id);
    expect(restored.catalogRef.kind, CatalogMediaKind.movie);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.targetRef?.entityType.apiValue, 'release');
    expect(restored.targetRef?.parentId, 'release-1');
    expect(restored.targetRef?.id, 'variant-1');
    expect(restored.condition, item.condition);
    expect(restored.grade, item.grade);
    expect(restored.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored.pricePaidCents, item.pricePaidCents);
    expect(restored.currency, item.currency);
    expect(restored.personalNotes, item.personalNotes);
    expect(restored.quantity, item.quantity);
    expect(restored.indexNumber, item.indexNumber);
    expect(restored.tags, item.tags);
    expect(restored.updatedAt.toUtc(), item.updatedAt);
    expect(restored.soldAt?.toUtc(), item.soldAt);
    expect(restored.sellPriceCents, item.sellPriceCents);
    expect(restored.soldTo, item.soldTo);
    expect(restored.ownerUserId, item.ownerUserId);
    expect(restored.ownerLabel, item.ownerLabel);
    expect(restored.locationId, item.locationId);
    expect(restored.purchaseStore, item.purchaseStore);
    expect(restored.collectionStatus, item.collectionStatus);
    expect(restored.marketValueCents, item.marketValueCents);
    expect(restored.details, item.details);
  });

  test('requires a persisted Movie owned-copy identity', () {
    expect(
      () => MovieOwnedLocalMapper.toRow(
        MovieOwnedItem(
          id: const MovieOwnedCopyId(''),
          catalogRef: const CatalogEntityRef(
            kind: CatalogMediaKind.movie,
            entityType: CatalogEntityTypeId('work'),
            id: 'movie-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
