import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/generic/add/generic_add_draft.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        final runtime = libraryKindRuntimeForKind(kind);
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
        expect(initialDraft.kind, kind,
            reason: '$kind initialDraft.kind must strictly match $kind');

        switch (kind) {
          case CatalogMediaKind.comic:
            expect(initialDraft, isA<ComicAddDraft>());
          case CatalogMediaKind.manga:
            expect(initialDraft, isA<MangaAddDraft>());
          case CatalogMediaKind.movie:
            expect(initialDraft, isA<MovieAddDraft>());
          case CatalogMediaKind.tv:
            expect(initialDraft, isA<TvAddDraft>());
          case CatalogMediaKind.anime:
            expect(initialDraft, isA<AnimeAddDraft>());
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

        final item = testCatalogItem(
          id: '${kind.apiValue}-test-1',
          kind: kind.apiValue,
          title: 'Test Item',
        );
        const common = LibraryAddCommonDraft(condition: 'Near Mint');

        final metadataItem = typedCatalogItemFromCatalogItem(item);
        final command = addCap.buildCommand(
          metadataItem,
          common,
          initialDraft,
          anchor: PersonalItemAnchor.fromRaw(
            anchorType: PersonalItemAnchorType.edition.apiValue,
            editionId: 'edition-${kind.apiValue}',
          ),
          tracking: const LibraryAddTrackingDraft(rating: 9),
        );
        expect(command.catalogRef.id, item.id);
        expect(command.anchor?.editionId, 'edition-${kind.apiValue}');
        expect(command.common.condition, 'Near Mint');
        expect(command.tracking?.rating, 9);
        expect(command.details, isNot(isA<GenericOwnedDetailsDraft>()),
            reason:
                '$kind command details must not be GenericOwnedDetailsDraft');

        switch (kind) {
          case CatalogMediaKind.comic:
            expect(command.details, isA<ComicOwnedDetailsDraft>());
          case CatalogMediaKind.manga:
            expect(command.details, isA<MangaOwnedDetailsDraft>());
          case CatalogMediaKind.movie:
            expect(command.details, isA<MovieOwnedDetailsDraft>());
          case CatalogMediaKind.tv:
            expect(command.details, isA<TvOwnedDetailsDraft>());
          case CatalogMediaKind.anime:
            expect(command.details, isA<AnimeOwnedDetailsDraft>());
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
        final runtime = libraryKindRuntimeForKind(kind);
        expect(runtime.kind, isNot(CatalogMediaKind.unknown));
        expect(runtime.add.kind, isNot(CatalogMediaKind.unknown));
        expect(runtime.add.createInitialDraft(), isNot(isA<GenericAddDraft>()));
      }
    });

    testWidgets('ComicAddManualPane uses standard visual primitives',
        (tester) async {
      final comicRuntime = libraryKindRuntimeForKind(CatalogMediaKind.comic);
      final draft = comicRuntime.add.createManualDraft() as ComicAddManualDraft;

      final request = LibraryAddManualPaneRequest(
        kind: CatalogMediaKind.comic,
        accent: Colors.blue,
        type: comicKindModule,
        manualDraft: draft,
        titleController: TextEditingController(text: 'Batman'),
        tagsController: TextEditingController(),
        personalNotesController: TextEditingController(),
        coverPriceController: TextEditingController(),
        priceController: TextEditingController(),
        purchaseDateController: TextEditingController(),
        purchaseStoreController: TextEditingController(),
        sellPriceController: TextEditingController(),
        soldDateController: TextEditingController(),
        ownerLabelController: TextEditingController(),
        linksController: TextEditingController(),
        isAdding: false,
        defaultCondition: 'Near Mint',
        defaultGrade: '9.4',
        defaultLocationLabel: null,
        defaultPurchaseDate: null,
        defaultTags: null,
        onAddOwned: () {},
        onAddWishlist: () {},
        onAddTrack: () {},
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ComicAddManualPane(request: request),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LibraryFormSection), findsOneWidget);
      expect(
          find.byType(AddSchemaRenderer<ComicAddManualDraft>), findsOneWidget);
      expect(find.byType(LibraryAddManualActionBar), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Collector'), findsOneWidget);
      expect(find.text('Series'), findsNWidgets(2));
      expect(find.text('Issue No.'), findsOneWidget);
      expect(find.text('Variant'), findsOneWidget);
      expect(find.text('Raw / Slabbed'), findsOneWidget);
      expect(find.text('Grading Co.'), findsOneWidget);
      expect(find.text('Certification No.'), findsOneWidget);
    });
  });
}
