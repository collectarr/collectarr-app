import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/stats/insurance_value.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  late LocalDatabase db;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('aggregates replacement values through kind-entry catalog codecs',
      () async {
    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-value-1',
        kind: 'comic',
        title: 'Value Comic',
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 2500,
        ),
      ),
    ]);
    await ComicEntryRepository(db).upsert(
      ComicLibraryEntry(
        id: const LibraryEntryId('entry-value-1'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId('library_entry'),
          id: 'comic-value-1',
        ),
        pricePaidCents: 1800,
        currency: 'USD',
        updatedAt: DateTime.utc(2026, 9, 8),
      ),
    );

    final summary = await InsuranceValueRepository(db).getSummary();

    expect(summary.totalItems, 1);
    expect(summary.itemsWithValue, 1);
    expect(summary.totalPaidCents, 1800);
    expect(summary.totalCoverPriceCents, 2500);
  });
}
