import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
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

  test('kind-entry detail drafts convert to JsonEncodable', () {
    const comicDraft = ComicEntryDetailsDraft(
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      coverPriceCents: 399,
    );
    final comicDetails = comicDraft.toDetails();
    expect(comicDetails.rawOrSlabbed, 'Slabbed');
    expect(comicDetails.gradingCompany, 'CGC');
    expect(comicDetails.coverPriceCents, 399);

    const videoDraft = MovieEntryDetailsDraft(
      features: 'Director Commentary',
      region: 'Region A',
    );
    final videoDetails = videoDraft.toDetails();
    expect(videoDetails.features, 'Director Commentary');
    expect(videoDetails.region, 'Region A');

    const gameDraft = GameEntryDetailsDraft(
      completeness: 'Loose',
      hasBox: false,
      hasManual: false,
    );
    final gameDetails = gameDraft.toDetails();
    expect(gameDetails.completeness, 'Loose');
    expect(gameDetails.hasBox, isFalse);

    const musicDraft = MusicEntryDetailsDraft(
      media: [
        MusicEntryMediumDetails(
          mediumIndex: 1,
          storageDevice: 'Shelf A',
          storageSlot: 'Slot 12',
        ),
      ],
    );
    final musicDetails = musicDraft.toDetails();
    expect(musicDetails.media.single.storageDevice, 'Shelf A');
    expect(musicDetails.media.single.storageSlot, 'Slot 12');
  });

  test(
      'CollectionMutations addLibraryEntry executes typed AddLibraryEntryCommand',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final command = typedAddLibraryEntryCommand(
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'comic-cmd-1',
      ),
      common: const LibraryAddCommonDraft(
        condition: 'Near Mint',
        pricePaidCents: 1500,
        currency: 'USD',
      ),
      grade: '9.8',
      details: const ComicEntryDetailsDraft(
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        certificationNumber: 'CGC-12345',
        coverPriceCents: 499,
      ),
    );

    final itemRef = await coordinator.addLibraryEntry(command);
    final item = await ComicEntryRepository(db)
        .findById(LibraryEntryId(itemRef.id.value));
    expect(item, isNotNull);
    final storedItem = item!;

    expect(storedItem.itemId, 'comic-cmd-1');
    expect(storedItem.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(storedItem.catalogRef.id, 'comic-cmd-1');
    expect(storedItem.condition, 'Near Mint');
    expect(storedItem.grade, '9.8');
    expect(storedItem.pricePaidCents, 1500);
    final comicDetails = storedItem.details;
    expect(comicDetails.gradingCompany, 'CGC');
    expect(comicDetails.certificationNumber, 'CGC-12345');
    expect(comicDetails.coverPriceCents, 499);
    final typedComicRows = await db.select(db.comicLibraryEntriesRows).get();
    expect(typedComicRows, hasLength(1));
    expect(typedComicRows.single.itemId, 'comic-cmd-1');
  });

  test(
      'CollectionCommandCoordinator updateLibraryEntry applies Patch operations via UpdateLibraryEntryCommand',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final initialRef = await coordinator.addLibraryEntry(
      typedAddLibraryEntryCommand(
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'comic-cmd-2',
        ),
        common: const LibraryAddCommonDraft(
          condition: 'Very Fine',
          pricePaidCents: 1000,
        ),
        grade: '8.0',
        details: const ComicEntryDetailsDraft(
          rawOrSlabbed: 'Raw',
        ),
      ),
    );

    final updatePayload = ComicLibraryEntryUpdatePayload.partial(
      condition: const Patch.set('Near Mint'),
      grade: const Patch.set('9.6'),
      details: const Patch.set(
        ComicEntryDetailsDraft(
          rawOrSlabbed: 'Slabbed',
          gradingCompany: 'CBCS',
        ),
      ),
    );

    final updatedRef = await coordinator.updateLibraryEntry(
      UpdateLibraryEntryCommand(
        libraryEntryRef: initialRef,
        payload: updatePayload,
      ),
    );

    expect(updatedRef.id, initialRef.id);
    final updated = await ComicEntryRepository(db)
        .findById(LibraryEntryId(updatedRef.id.value));
    expect(updated, isNotNull);
    final updatedItem = updated!;
    expect(updatedItem.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(updatedItem.catalogRef.id, 'comic-cmd-2');
    expect(updatedItem.condition, 'Near Mint');
    expect(updatedItem.grade, '9.6');
    expect(updatedItem.pricePaidCents, 1000);
    final comicDetails = updatedItem.details;
    expect(comicDetails.rawOrSlabbed, 'Slabbed');
    expect(comicDetails.gradingCompany, 'CBCS');
  });
}
