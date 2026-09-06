import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_details_codecs.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const allActiveKinds = [
    CatalogMediaKind.comic,
    CatalogMediaKind.manga,
    CatalogMediaKind.anime,
    CatalogMediaKind.book,
    CatalogMediaKind.game,
    CatalogMediaKind.boardgame,
    CatalogMediaKind.movie,
    CatalogMediaKind.tv,
    CatalogMediaKind.music,
  ];

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

  group('Typed Owned Commands & Details', () {
    test(
        'every registered active kind accepts valid typed details and rejects mismatched details',
        () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(collectionCommandCoordinatorProvider);

      final kindDetailsMap = <CatalogMediaKind, OwnedDetailsDraft>{
        CatalogMediaKind.comic:
            const ComicOwnedDetailsDraft(gradingCompany: 'CGC'),
        CatalogMediaKind.manga:
            const MangaOwnedDetailsDraft(gradingCompany: 'CBCS'),
        CatalogMediaKind.movie: const MovieOwnedDetailsDraft(region: 'A'),
        CatalogMediaKind.tv: const TvOwnedDetailsDraft(region: 'B'),
        CatalogMediaKind.anime: const AnimeOwnedDetailsDraft(region: 'Free'),
        CatalogMediaKind.game: const GameOwnedDetailsDraft(hasBox: true),
        CatalogMediaKind.music:
            const MusicOwnedDetailsDraft(storageDevice: 'Shelf A'),
        CatalogMediaKind.book: const BookOwnedDetailsDraft(),
        CatalogMediaKind.boardgame: const BoardgameOwnedDetailsDraft(),
      };

      for (final entry in kindDetailsMap.entries) {
        final kind = entry.key;
        final validDraft = entry.value;

        final item = await coordinator.addOwnedItem(
          typedAddOwnedItemCommand(
            catalogRef: CatalogEntityRef(
              kind: kind.apiValue,
              entityType: CatalogEntityType.ownedCopy,
              id: 'test-${kind.apiValue}-1',
            ),
            common: const LibraryAddCommonDraft(),
            details: validDraft,
          ),
        );

        final defaultDetails =
            collectarrOwnedDetailsCodecForKind(kind).defaultDetails();
        expect(item.details, isNot(isA<GenericOwnedDetails>()));
        expect(item.details.runtimeType, defaultDetails.runtimeType);

        // Mismatched details test: non-comic kind with ComicOwnedDetailsDraft
        if (kind != CatalogMediaKind.comic && kind != CatalogMediaKind.manga) {
          expect(
            () => coordinator.addOwnedItem(
              typedAddOwnedItemCommand(
                catalogRef: CatalogEntityRef(
                  kind: kind.apiValue,
                  entityType: CatalogEntityType.ownedCopy,
                  id: 'test-${kind.apiValue}-bad',
                ),
                common: const LibraryAddCommonDraft(),
                details: const ComicOwnedDetailsDraft(gradingCompany: 'CGC'),
              ),
            ),
            throwsA(isA<StateError>()),
          );
        } else {
          // Comic/manga kind with MovieOwnedDetailsDraft
          expect(
            () => coordinator.addOwnedItem(
              typedAddOwnedItemCommand(
                catalogRef: CatalogEntityRef(
                  kind: kind.apiValue,
                  entityType: CatalogEntityType.ownedCopy,
                  id: 'test-${kind.apiValue}-bad',
                ),
                common: const LibraryAddCommonDraft(),
                details: const MovieOwnedDetailsDraft(region: 'A'),
              ),
            ),
            throwsA(isA<StateError>()),
          );
        }
      }
    });

    test(
        'updating details with Patch.clear resets to kind default empty details, never GenericOwnedDetails for all 9 kinds',
        () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(collectionCommandCoordinatorProvider);

      for (final kind in allActiveKinds) {
        final initial = await coordinator.addOwnedItem(
          typedAddOwnedItemCommand(
            catalogRef: CatalogEntityRef(
              kind: kind.apiValue,
              entityType: CatalogEntityType.ownedCopy,
              id: 'clear-test-${kind.apiValue}',
            ),
            common: const LibraryAddCommonDraft(),
            details: libraryKindOwnedDetailsDraftForKind(kind),
          ),
        );

        final updated = await coordinator.updateOwnedItem(
          OwnedItemPatchCommand<OwnedDetailsDraft>(
            ownedItemId: initial.id,
            details: const Patch.clear(),
          ),
        );

        final defaultDetails =
            collectarrOwnedDetailsCodecForKind(kind).defaultDetails();

        expect(updated.details, isNot(isA<GenericOwnedDetails>()));
        expect(updated.details.runtimeType, defaultDetails.runtimeType);
      }
    });

    test('default details for all 9 kinds resolves to non-generic details', () {
      for (final kind in allActiveKinds) {
        final defaultDetails =
            collectarrOwnedDetailsCodecForKind(kind).defaultDetails();
        expect(defaultDetails, isNot(isA<GenericOwnedDetails>()),
            reason: '$kind default details must not be GenericOwnedDetails');

        final defaultDraft = libraryKindOwnedDetailsDraftForKind(kind);
        expect(defaultDraft, isNot(isA<GenericOwnedDetailsDraft>()),
            reason: '$kind default draft must not be GenericOwnedDetailsDraft');
      }
    });

    test('unknown kind has no owned details registration', () {
      expect(
        () => libraryKindOwnedDetailsDraftForKind(CatalogMediaKind.unknown),
        throwsArgumentError,
      );
    });

    test(
        'round-trip JSON parsing and serialization preserves concrete kind details',
        () {
      const book = BookOwnedDetails();
      const boardgame = BoardgameOwnedDetails();

      expect(book.toJson(), isEmpty);
      expect(boardgame.toJson(), isEmpty);

      final parsedBook = collectarrOwnedDetailsCodecForKind(
        CatalogMediaKind.book,
      ).fromJson({});
      final parsedBoardgame = collectarrOwnedDetailsCodecForKind(
        CatalogMediaKind.boardgame,
      ).fromJson({});

      expect(parsedBook, isA<BookOwnedDetails>());
      expect(parsedBoardgame, isA<BoardgameOwnedDetails>());

      expect(
        libraryKindOwnedDetailsDraftFromDetailsForKind(
          CatalogMediaKind.book,
          parsedBook,
        ),
        isA<BookOwnedDetailsDraft>(),
      );
      expect(
        libraryKindOwnedDetailsDraftFromDetailsForKind(
          CatalogMediaKind.boardgame,
          parsedBoardgame,
        ),
        isA<BoardgameOwnedDetailsDraft>(),
      );
    });
  });
}
