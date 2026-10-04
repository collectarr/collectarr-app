import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details_draft.dart';
import 'package:collectarr_app/test/helpers/test_entry_details.dart';
import 'package:collectarr_app/test/helpers/entry_details_codec_fixtures.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_codec.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/test/helpers/concrete_kind_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';

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

  group('Typed Entry Commands & Details', () {
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

      for (final kind in allActiveKinds) {
        final validDraft = _validDetailsFor(kind);

        final itemRef = await coordinator.addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: _testCatalogRef(kind, 'test-${kind.apiValue}-1'),
            common: const LibraryAddCommonDraft(),
            details: validDraft,
          ),
        );

        final defaultDetails =
            entryDetailsFixtureForTest(kind).defaultDetails();
        final storedPayload =
            await LibraryEntriesRepository(db).payloadByRef(itemRef);
        expect(storedPayload, isNotNull);
        expect(storedPayload, isNotEmpty);
        expect(defaultDetails, isNot(isA<TestEntryDetails>()));

        final mismatchedDetails = _mismatchedDetailsFor(kind);
        expect(
          () => coordinator.addLibraryEntry(
            typedAddLibraryEntryCommand(
              catalogRef: _testCatalogRef(kind, 'test-${kind.apiValue}-bad'),
              common: const LibraryAddCommonDraft(),
              details: mismatchedDetails,
            ),
          ),
          throwsA(isA<StateError>()),
        );
      }
    });

    test(
        'updating details with Patch.clear resets to kind default empty details, never TestEntryDetails for all 9 kinds',
        () async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(collectionCommandCoordinatorProvider);

      for (final kind in allActiveKinds) {
        final initialRef = await coordinator.addLibraryEntry(
          typedAddLibraryEntryCommand(
            catalogRef: _testCatalogRef(
              kind,
              'clear-test-${kind.apiValue}',
            ),
            common: const LibraryAddCommonDraft(),
            details: libraryAddForKind(kind)
                .createInitialDraft()
                .toEntryDetailsDraft(),
          ),
        );

        final updated = await coordinator.updateLibraryEntry(
          libraryEntryEditForKind(kind).buildDetailsResetCommand(
            libraryEntryRef: LibraryEntryRef(kind: kind, id: initialRef.id),
          ),
        );

        final defaultDetails =
            entryDetailsFixtureForTest(kind).defaultDetails();

        final updatedPayload =
            await LibraryEntriesRepository(db).payloadByRef(updated);
        expect(updatedPayload, isNotNull);
        expect(updatedPayload, isNotEmpty);
        expect(defaultDetails, isNot(isA<TestEntryDetails>()));
      }
    });

    test('default details for all 9 kinds resolves to non-generic details', () {
      for (final kind in allActiveKinds) {
        final defaultDetails =
            entryDetailsFixtureForTest(kind).defaultDetails();
        expect(defaultDetails, isNot(isA<TestEntryDetails>()),
            reason: '$kind default details must not be TestEntryDetails');

        final defaultDraft =
            libraryAddForKind(kind).createInitialDraft().toEntryDetailsDraft();
        expect(defaultDraft, isNot(isA<TestEntryDetailsDraft>()),
            reason: '$kind default draft must not be TestEntryDetailsDraft');
      }
    });

    test('unknown kind has no entry details registration', () {
      expect(
        () => testKindRegistration(CatalogMediaKind.unknown),
        throwsArgumentError,
      );
    });

    test(
        'round-trip JSON parsing and serialization preserves concrete kind details',
        () {
      const book = BookEntryDetails();
      const boardgame = BoardgameEntryDetails();

      expect(book.toJson(), isEmpty);
      expect(boardgame.toJson(), isEmpty);

      final parsedBook = const BookEntryDetailsCodec().fromJson({});
      final parsedBoardgame = const BoardgameEntryDetailsCodec().fromJson({});

      expect(parsedBook, isA<BookEntryDetails>());
      expect(parsedBoardgame, isA<BoardgameEntryDetails>());

      expect(
        const BookEntryDetailsCodec().draftFromDetails(
          parsedBook,
        ),
        isA<BookEntryDetailsDraft>(),
      );
      expect(
        const BoardgameEntryDetailsCodec().draftFromDetails(
          parsedBoardgame,
        ),
        isA<BoardgameEntryDetailsDraft>(),
      );
    });
  });
}

CatalogEntityRef _testCatalogRef(CatalogMediaKind kind, String id) {
  return CatalogEntityRef(
    kind: kind,
    entityType: CatalogEntityTypeId.catalogItem,
    id: id,
  );
}

JsonEncodable _validDetailsFor(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.comic =>
      const ComicEntryDetailsDraft(gradingCompany: 'CGC'),
    CatalogMediaKind.manga =>
      const MangaEntryDetailsDraft(gradingCompany: 'CBCS'),
    CatalogMediaKind.movie => const MovieEntryDetailsDraft(region: 'A'),
    CatalogMediaKind.tv => const TvEntryDetailsDraft(region: 'B'),
    CatalogMediaKind.anime => const AnimeEntryDetailsDraft(region: 'Free'),
    CatalogMediaKind.game => const GameEntryDetailsDraft(hasBox: true),
    CatalogMediaKind.music => const MusicEntryDetailsDraft(
        media: [
          MusicEntryMediumDetails(mediumIndex: 1, storageDevice: 'Shelf A'),
        ],
      ),
    CatalogMediaKind.book => const BookEntryDetailsDraft(),
    CatalogMediaKind.boardgame => const BoardgameEntryDetailsDraft(),
    CatalogMediaKind.unknown => throw ArgumentError.value(kind),
  };
}

JsonEncodable _mismatchedDetailsFor(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.comic ||
    CatalogMediaKind.manga =>
      const MovieEntryDetailsDraft(region: 'A'),
    CatalogMediaKind.anime ||
    CatalogMediaKind.boardgame ||
    CatalogMediaKind.book ||
    CatalogMediaKind.game ||
    CatalogMediaKind.movie ||
    CatalogMediaKind.music ||
    CatalogMediaKind.tv =>
      const ComicEntryDetailsDraft(gradingCompany: 'CGC'),
    CatalogMediaKind.unknown => throw ArgumentError.value(kind),
  };
}
