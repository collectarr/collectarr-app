import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_entry_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete Movie collection item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MovieLibraryEntry(
      id: const LibraryEntryId('entry-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'movie-1',
      ),
      createdAt: DateTime.utc(2026, 1, 2),
      isDigital: false,
      condition: 'Near Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 1, 3),
      pricePaidCents: 2499,
      currency: 'USD',
      personalNotes: 'Collector copy',
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
      collectionStatus: 'entry',
      marketValueCents: 3500,
      details: const MovieEntryDetails(
        features: 'Director commentary',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        boxSetId: 'box-1',
        boxSetName: 'The Matrix Collection',
        region: 'A',
        packaging: 'SteelBook',
        distributor: 'Warner Home Video',
      ),
    );

    await db.into(db.movieLibraryEntriesRows).insert(
          MovieEntryLocalMapper.toRow(item),
        );
    final row = await db.select(db.movieLibraryEntriesRows).getSingle();
    final restored = MovieEntryLocalMapper.fromRow(row);

    expect(restored.id, item.id);
    expect(restored.catalogRef.kind, CatalogMediaKind.movie);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.condition, item.condition);
    expect(restored.grade, item.grade);
    expect(restored.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored.pricePaidCents, item.pricePaidCents);
    expect(restored.currency, item.currency);
    expect(restored.personalNotes, item.personalNotes);
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

  test('requires a persisted Movie collection-item identity', () {
    expect(
      () => MovieEntryLocalMapper.toRow(
        MovieLibraryEntry(
          id: const LibraryEntryId(''),
          catalogRef: const CatalogEntityRef(
            kind: CatalogMediaKind.movie,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'movie-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
