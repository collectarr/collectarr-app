import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Typed Owned Commands & Details', () {
    test('every registered active kind accepts valid details and rejects wrong details', () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(collectionCommandCoordinatorProvider);

      final kindDetailsMap = <CatalogMediaKind, OwnedDetailsDraft>{
        CatalogMediaKind.comic: const ComicOwnedDetailsDraft(gradingCompany: 'CGC'),
        CatalogMediaKind.manga: const ComicOwnedDetailsDraft(gradingCompany: 'CBCS'),
        CatalogMediaKind.movie: const VideoOwnedDetailsDraft(region: 'A'),
        CatalogMediaKind.tv: const VideoOwnedDetailsDraft(region: 'B'),
        CatalogMediaKind.anime: const VideoOwnedDetailsDraft(region: 'Free'),
        CatalogMediaKind.game: const GameOwnedDetailsDraft(hasBox: true),
        CatalogMediaKind.music: const MusicOwnedDetailsDraft(storageDevice: 'Shelf A'),
        CatalogMediaKind.book: const BookOwnedDetailsDraft(),
        CatalogMediaKind.boardgame: const BoardgameOwnedDetailsDraft(),
      };

      for (final entry in kindDetailsMap.entries) {
        final kind = entry.key;
        final validDraft = entry.value;

        final item = await coordinator.addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: CatalogEntityRef(
              kind: kind.apiValue,
              entityType: CatalogEntityType.ownedCopy,
              id: 'test-${kind.apiValue}-1',
            ),
            common: const OwnedItemCommonDraft(),
            details: validDraft,
          ),
        );

        final runtime = LibraryKindRegistry.instance.getByKind(kind);
        expect(item.details, isNot(isA<GenericOwnedDetails>()));
        expect(item.details.runtimeType, runtime.defaultOwnedDetails().runtimeType);

        // Mismatched details test: movie kind with ComicOwnedDetailsDraft
        if (kind != CatalogMediaKind.comic && kind != CatalogMediaKind.manga) {
          expect(
            () => coordinator.addOwnedItem(
              AddOwnedItemCommand(
                catalogRef: CatalogEntityRef(
                  kind: kind.apiValue,
                  entityType: CatalogEntityType.ownedCopy,
                  id: 'test-${kind.apiValue}-bad',
                ),
                common: const OwnedItemCommonDraft(),
                details: const ComicOwnedDetailsDraft(gradingCompany: 'CGC'),
              ),
            ),
            throwsA(isA<ArgumentError>()),
          );
        } else {
          // Comic/manga kind with VideoOwnedDetailsDraft
          expect(
            () => coordinator.addOwnedItem(
              AddOwnedItemCommand(
                catalogRef: CatalogEntityRef(
                  kind: kind.apiValue,
                  entityType: CatalogEntityType.ownedCopy,
                  id: 'test-${kind.apiValue}-bad',
                ),
                common: const OwnedItemCommonDraft(),
                details: const VideoOwnedDetailsDraft(region: 'A'),
              ),
            ),
            throwsA(isA<ArgumentError>()),
          );
        }
      }
    });

    test('updating details with Patch.clear resets to kind default empty details, never GenericOwnedDetails', () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(collectionCommandCoordinatorProvider);

      final kinds = [
        CatalogMediaKind.comic,
        CatalogMediaKind.movie,
        CatalogMediaKind.game,
        CatalogMediaKind.music,
        CatalogMediaKind.book,
        CatalogMediaKind.boardgame,
      ];

      for (final kind in kinds) {
        final initial = await coordinator.addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: CatalogEntityRef(
              kind: kind.apiValue,
              entityType: CatalogEntityType.ownedCopy,
              id: 'clear-test-${kind.apiValue}',
            ),
            common: const OwnedItemCommonDraft(),
            details: defaultDetailsDraftForKind(kind),
          ),
        );

        final updated = await coordinator.updateOwnedItem(
          UpdateOwnedItemCommand(
            ownedItemId: initial.id,
            details: const Patch.clear(),
          ),
        );

        final runtime = LibraryKindRegistry.instance.getByKind(kind);
        final defaultDetails = runtime.defaultOwnedDetails();

        expect(updated.details, isNot(isA<GenericOwnedDetails>()));
        expect(updated.details.runtimeType, defaultDetails.runtimeType);
      }
    });

    test('round-trip JSON parsing and serialization preserves concrete kind details', () {
      const book = BookOwnedDetails();
      const boardgame = BoardgameOwnedDetails();

      expect(book.toJson(), isEmpty);
      expect(boardgame.toJson(), isEmpty);

      final parsedBook = OwnedItemDetails.parseForKind(CatalogMediaKind.book, {});
      final parsedBoardgame = OwnedItemDetails.parseForKind(CatalogMediaKind.boardgame, {});

      expect(parsedBook, isA<BookOwnedDetails>());
      expect(parsedBoardgame, isA<BoardgameOwnedDetails>());

      expect(parsedBook.toDraft(), isA<BookOwnedDetailsDraft>());
      expect(parsedBoardgame.toDraft(), isA<BoardgameOwnedDetailsDraft>());
    });
  });
}
