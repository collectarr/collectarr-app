import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_collection_item_create_payload.dart';

void main() {
  test('collection add writes every active kind to its typed owned table',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    const kinds = [
      CatalogMediaKind.comic,
      CatalogMediaKind.manga,
      CatalogMediaKind.book,
      CatalogMediaKind.game,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.movie,
      CatalogMediaKind.tv,
      CatalogMediaKind.anime,
      CatalogMediaKind.music,
    ];

    for (final kind in kinds) {
      final rootRef = CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'contract-owned-${kind.apiValue}',
      );
      await coordinator.addCollectionItem(
        typedAddCollectionItemCommand(
          catalogRef: rootRef,
          common: const LibraryAddCommonDraft(
            condition: 'Good',
          ),
          details: libraryAddForKind(kind)
              .createInitialDraft()
              .toOwnedDetailsDraft(),
          typedPayload: kind == CatalogMediaKind.music
              ? MusicCollectionItemCreatePayload(
                  catalogRef: rootRef,
                  details: const MusicOwnedDetailsDraft(),
                )
              : null,
        ),
      );
    }

    expect(await db.select(db.comicCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.mangaCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.bookCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.gameCollectionItemsRows).get(), hasLength(1));
    expect(
        await db.select(db.boardGameCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.movieCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.tvCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.animeCollectionItemsRows).get(), hasLength(1));
    expect(await db.select(db.musicCollectionItemsRows).get(), hasLength(1));
  });
}
