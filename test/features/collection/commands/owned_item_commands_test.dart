import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Collectarr Test',
      packageName: 'com.collectarr.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });
  test('Patch model supports unchanged, set, and clear operations', () {
    const p1 = Patch<String>.unchanged();
    const p2 = Patch<String>.set('hello');
    const p3 = Patch<String>.clear();

    expect(p1.valueOrNull(), isNull);
    expect(p2.valueOrNull(), 'hello');
    expect(p3.valueOrNull(), isNull);

    expect(
      p1.when(unchanged: () => 1, set: (_) => 2, clear: () => 3),
      1,
    );
    expect(
      p2.when(unchanged: () => 1, set: (v) => v.length, clear: () => 3),
      5,
    );
    expect(
      p3.when(unchanged: () => 1, set: (_) => 2, clear: () => 3),
      3,
    );
  });

  test('OwnedDetailsDraft converts to corresponding JsonEncodable', () {
    const comicDraft = ComicOwnedDetailsDraft(
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      coverPriceCents: 399,
    );
    final comicDetails = comicDraft.toDetails();
    expect(comicDetails.rawOrSlabbed, 'Slabbed');
    expect(comicDetails.gradingCompany, 'CGC');
    expect(comicDetails.coverPriceCents, 399);

    const videoDraft = MovieOwnedDetailsDraft(
      features: 'Director Commentary',
      region: 'Region A',
    );
    final videoDetails = videoDraft.toDetails();
    expect(videoDetails.features, 'Director Commentary');
    expect(videoDetails.region, 'Region A');

    const gameDraft = GameOwnedDetailsDraft(
      completeness: 'Loose',
      hasBox: false,
      hasManual: false,
    );
    final gameDetails = gameDraft.toDetails();
    expect(gameDetails.completeness, 'Loose');
    expect(gameDetails.hasBox, isFalse);

    const musicDraft = MusicOwnedDetailsDraft(
      storageDevice: 'Shelf A',
      storageSlot: 'Slot 12',
    );
    final musicDetails = musicDraft.toDetails();
    expect(musicDetails.storageDevice, 'Shelf A');
    expect(musicDetails.storageSlot, 'Slot 12');
  });

  test('CollectionMutations addOwnedItem executes typed AddOwnedItemCommand',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final command = typedAddOwnedItemCommand(
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: const CatalogEntityTypeId('owned_copy'),
        id: 'comic-cmd-1',
      ),
      targetRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId('release'),
        id: 'variant-1',
        rootId: 'comic-cmd-1',
        parentId: 'edition-1',
      ),
      common: const LibraryAddCommonDraft(
        condition: 'Near Mint',
        grade: '9.8',
        pricePaidCents: 1500,
        currency: 'USD',
        quantity: 1,
      ),
      details: const ComicOwnedDetailsDraft(
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        certificationNumber: 'CGC-12345',
        coverPriceCents: 499,
      ),
    );

    final itemRef = await coordinator.addOwnedItem(command);
    final stored = await OwnedItemsRepository(db).findTypedByRef(itemRef);
    final item = stored!.$2 as ComicOwnedItem;

    expect(item.itemId, 'comic-cmd-1');
    expect(item.targetRef?.entityType.apiValue, 'release');
    expect(item.targetRef?.parentId, 'edition-1');
    expect(item.targetRef?.id, 'variant-1');
    expect(item.condition, 'Near Mint');
    expect(item.grade, '9.8');
    expect(item.pricePaidCents, 1500);
    final comicDetails = item.details;
    expect(comicDetails.gradingCompany, 'CGC');
    expect(comicDetails.certificationNumber, 'CGC-12345');
    expect(comicDetails.coverPriceCents, 499);
    final typedComicRows = await db.select(db.comicOwnedItemsRows).get();
    expect(typedComicRows, hasLength(1));
    expect(typedComicRows.single.itemId, 'comic-cmd-1');
  });

  test(
      'CollectionCommandCoordinator updateOwnedItem applies Patch operations via UpdateOwnedItemCommand',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final initialRef = await coordinator.addOwnedItem(
      typedAddOwnedItemCommand(
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('owned_copy'),
          id: 'comic-cmd-2',
        ),
        common: const LibraryAddCommonDraft(
          condition: 'Very Fine',
          grade: '8.0',
          pricePaidCents: 1000,
        ),
        details: const ComicOwnedDetailsDraft(
          rawOrSlabbed: 'Raw',
        ),
      ),
    );

    final updatePayload = ComicOwnedItemUpdatePayload.partial(
      targetRef: Patch.set(
        const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId('release'),
          id: 'variant-updated',
          rootId: 'comic-cmd-2',
          parentId: 'edition-updated',
        ),
      ),
      condition: const Patch.set('Near Mint'),
      grade: const Patch.set('9.6'),
      details: const Patch.set(
        ComicOwnedDetailsDraft(
          rawOrSlabbed: 'Slabbed',
          gradingCompany: 'CBCS',
        ),
      ),
    );

    final updatedRef = await coordinator.updateOwnedItem(
      UpdateOwnedItemCommand(
        ownedRef: initialRef,
        payload: updatePayload,
      ),
    );

    expect(updatedRef.id, initialRef.id);
    final updatedStored =
        await OwnedItemsRepository(db).findTypedByRef(updatedRef);
    final updated = updatedStored!.$2 as ComicOwnedItem;
    expect(updated.targetRef?.entityType.apiValue, 'release');
    expect(updated.targetRef?.parentId, 'edition-updated');
    expect(updated.targetRef?.id, 'variant-updated');
    expect(updated.condition, 'Near Mint');
    expect(updated.grade, '9.6');
    expect(updated.pricePaidCents, 1000);
    final comicDetails = updated.details;
    expect(comicDetails.rawOrSlabbed, 'Slabbed');
    expect(comicDetails.gradingCompany, 'CBCS');
  });
}
