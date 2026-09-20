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
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_create_payload.dart';

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
        entityType: const CatalogEntityTypeId('work'),
        id: 'contract-owned-${kind.apiValue}',
      );
      final releaseRef = CatalogEntityRef(
        kind: kind,
        entityType: const CatalogEntityTypeId('release'),
        id: '${rootRef.id}:release',
        rootId: rootRef.id,
      );
      await coordinator.addOwnedItem(
        typedAddOwnedItemCommand(
          catalogRef: rootRef,
          targetRef: kind == CatalogMediaKind.music ? releaseRef : rootRef,
          common: const LibraryAddCommonDraft(
            condition: 'Good',
          ),
          details: libraryAddForKind(kind)
              .createInitialDraft()
              .toOwnedDetailsDraft(),
          typedPayload: kind == CatalogMediaKind.music
              ? MusicOwnedItemCreatePayload(
                  catalogRef: rootRef,
                  releaseRef: releaseRef,
                  details: const MusicOwnedDetailsDraft(),
                )
              : null,
        ),
      );
    }

    expect(await db.select(db.comicOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.mangaOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.bookOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.gameOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.boardGameOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.movieOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.tvOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.animeOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.musicOwnedItemsRows).get(), hasLength(1));
  });
}
