import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/sync/provider_local_state_bridge.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('reads provider fields from a persistent tracking entry', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = LibraryCatalogRepository(db);
    final tracking = TrackingEntriesCacheRepository(db);
    final bridge = ProviderLocalStateBridge(
      catalogCache: catalog,
      trackingEntries: tracking,
      wishlist: WishlistItemsCacheRepository(db),
    );
    final item = testCatalogItem(
      id: 'movie-1',
      kind: 'movie',
      title: 'A Movie',
    );
    await catalog.upsertAll([item]);
    const localRef = CatalogEntityRef(
      id: 'movie-1',
      kind: 'movie',
      entityType: CatalogEntityType.work,
    );
    await tracking.upsert(
      TrackingEntry(
        id: 'tracking-1',
        catalogRef: localRef,
        status: MediaTrackingStatus.completed,
        rating: 8,
        progressCurrent: 1,
        progressTotal: 1,
        timesCompleted: 2,
        notes: 'Finished',
        updatedAt: DateTime.utc(2026, 6, 1),
        deletedAt: null,
      ),
    );

    final entry = await bridge.read(localRef);

    expect(entry, isNotNull);
    expect(entry!.title, 'A Movie');
    expect(entry.status?.name, 'completed');
    expect(entry.rating, 80);
    expect(entry.progress, 1);
    expect(entry.totalProgress, 1);
    expect(entry.repeatCount, 2);
    expect(entry.notes, 'Finished');
  });
}
