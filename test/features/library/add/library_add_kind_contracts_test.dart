import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const activeKinds = [
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

  group('Library Kind Add Capability Contract Tests', () {
    test('all 9 active kinds have explicit add capability and correct drafts',
        () {
      for (final kind in activeKinds) {
        final runtime = LibraryKindRegistry.instance.getByKind(kind);
        expect(runtime, isNotNull,
            reason: '$kind must be registered in LibraryKindRegistry');

        final addCap = runtime.add;
        expect(addCap, isNotNull,
            reason: '$kind must have an explicit add capability');
        expect(addCap.kind, kind,
            reason:
                '$kind capability must explicitly match kind (no unknown fallback)');

        final initialDraft = addCap.createInitialDraft();
        expect(initialDraft, isNot(isA<GenericAddDraft>()),
            reason: '$kind must not produce a GenericAddDraft');

        switch (kind) {
          case CatalogMediaKind.comic:
          case CatalogMediaKind.manga:
            expect(initialDraft, isA<ComicAddDraft>());
          case CatalogMediaKind.movie:
          case CatalogMediaKind.tv:
          case CatalogMediaKind.anime:
            expect(initialDraft, isA<VideoAddDraft>());
          case CatalogMediaKind.book:
            expect(initialDraft, isA<BookAddDraft>());
          case CatalogMediaKind.game:
            expect(initialDraft, isA<GameAddDraft>());
          case CatalogMediaKind.boardgame:
            expect(initialDraft, isA<BoardGameAddDraft>());
          case CatalogMediaKind.music:
            expect(initialDraft, isA<MusicAddDraft>());
          case CatalogMediaKind.unknown:
            fail('Unknown kind is not an active kind');
        }

        final item = CatalogItem(
          id: '${kind.apiValue}-test-1',
          kind: kind.apiValue,
          title: 'Test Item',
        );
        const common = LibraryAddCommonDraft(condition: 'Near Mint', rating: 9);

        final command = addCap.buildCommand(item, common, initialDraft);
        expect(command.catalogRef.id, item.id);
        expect(command.common.condition, 'Near Mint');
        expect(command.common.rating, 9);
        expect(command.details, isNot(isA<GenericOwnedDetailsDraft>()),
            reason:
                '$kind command details must not be GenericOwnedDetailsDraft');

        switch (kind) {
          case CatalogMediaKind.comic:
          case CatalogMediaKind.manga:
            expect(command.details, isA<ComicOwnedDetailsDraft>());
          case CatalogMediaKind.movie:
          case CatalogMediaKind.tv:
          case CatalogMediaKind.anime:
            expect(command.details, isA<VideoOwnedDetailsDraft>());
          case CatalogMediaKind.book:
            expect(command.details, isA<BookOwnedDetailsDraft>());
          case CatalogMediaKind.game:
            expect(command.details, isA<GameOwnedDetailsDraft>());
          case CatalogMediaKind.boardgame:
            expect(command.details, isA<BoardgameOwnedDetailsDraft>());
          case CatalogMediaKind.music:
            expect(command.details, isA<MusicOwnedDetailsDraft>());
          case CatalogMediaKind.unknown:
            fail('Unknown kind is not an active kind');
        }
      }
    });

    test(
        'no supported kind resolves to unknown or generic fallback in registry',
        () {
      for (final kind in activeKinds) {
        final runtime = LibraryKindRegistry.instance.getByKind(kind);
        expect(runtime.kind, isNot(CatalogMediaKind.unknown));
        expect(runtime.add.kind, isNot(CatalogMediaKind.unknown));
        expect(runtime.add.createInitialDraft(), isNot(isA<GenericAddDraft>()));
      }
    });
  });
}
