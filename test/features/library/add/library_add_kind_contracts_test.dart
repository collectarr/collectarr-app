import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/test/helpers/test_owned_details.dart';
import 'package:collectarr_app/test/helpers/concrete_kind_dispatch.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void _expectDuplicatedOwnedFields(Object owned) {
  switch (owned) {
    case AnimeOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case BoardGameOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case BookOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case ComicOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case GameOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case MangaOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case MovieOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case MusicOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    case TvOwnedItem item:
      _expectOwnedFields(item.condition, item.grade, item.personalNotes,
          item.purchaseStore, item.collectionStatus, item.quantity);
    default:
      fail('Unexpected non-kind Owned value: ${owned.runtimeType}');
  }
}

void _expectOwnedFields(
  String? condition,
  String? grade,
  String? personalNotes,
  String? purchaseStore,
  String? collectionStatus,
  int quantity,
) {
  expect(condition, 'Near Mint');
  expect(grade, '9.8');
  expect(personalNotes, 'Collection note');
  expect(purchaseStore, 'Typed Store');
  expect(collectionStatus, 'Complete');
  expect(quantity, 2);
}

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
      const expectedAddDraftTypes = <CatalogMediaKind, Type>{
        CatalogMediaKind.comic: ComicAddDraft,
        CatalogMediaKind.manga: MangaAddDraft,
        CatalogMediaKind.movie: MovieAddDraft,
        CatalogMediaKind.tv: TvAddDraft,
        CatalogMediaKind.anime: AnimeAddDraft,
        CatalogMediaKind.book: BookAddDraft,
        CatalogMediaKind.game: GameAddDraft,
        CatalogMediaKind.boardgame: BoardgameAddDraft,
        CatalogMediaKind.music: MusicAddDraft,
      };
      const expectedOwnedDetailsDraftTypes = <CatalogMediaKind, Type>{
        CatalogMediaKind.comic: ComicOwnedDetailsDraft,
        CatalogMediaKind.manga: MangaOwnedDetailsDraft,
        CatalogMediaKind.movie: MovieOwnedDetailsDraft,
        CatalogMediaKind.tv: TvOwnedDetailsDraft,
        CatalogMediaKind.anime: AnimeOwnedDetailsDraft,
        CatalogMediaKind.book: BookOwnedDetailsDraft,
        CatalogMediaKind.game: GameOwnedDetailsDraft,
        CatalogMediaKind.boardgame: BoardgameOwnedDetailsDraft,
        CatalogMediaKind.music: MusicOwnedDetailsDraft,
      };
      for (final kind in activeKinds) {
        final runtime = testKindModule(kind);
        expect(runtime, isNotNull,
            reason: '$kind must be registered in LibraryKindRegistry');

        final addCap = runtime.add;
        expect(addCap, isNotNull,
            reason: '$kind must have an explicit add capability');
        expect(addCap.kind, kind,
            reason:
                '$kind capability must explicitly match kind (no unknown fallback)');

        final initialDraft = addCap.createInitialDraft();
        expect(initialDraft.kind, kind,
            reason: '$kind initialDraft.kind must strictly match $kind');

        expect(
          initialDraft.runtimeType,
          expectedAddDraftTypes[kind],
          reason: '$kind must expose its concrete add draft type',
        );

        final item = testCatalogItem(
          id: '${kind.apiValue}-test-1',
          kind: kind.apiValue,
          title: 'Test Item',
        );
        const common = LibraryAddCommonDraft(
          condition: 'Near Mint',
          personalNotes: 'Collection note',
          purchaseStore: 'Typed Store',
          collectionStatus: 'Complete',
          quantity: 2,
        );
        final typedDraft = switch (kind) {
          CatalogMediaKind.anime => AnimeAddDraft(grade: '9.8'),
          CatalogMediaKind.boardgame => BoardgameAddDraft(grade: '9.8'),
          CatalogMediaKind.book => BookAddDraft(grade: '9.8'),
          CatalogMediaKind.comic => ComicAddDraft(grade: '9.8'),
          CatalogMediaKind.game => GameAddDraft(grade: '9.8'),
          CatalogMediaKind.manga => MangaAddDraft(grade: '9.8'),
          CatalogMediaKind.movie => MovieAddDraft(grade: '9.8'),
          CatalogMediaKind.music => MusicAddDraft(grade: '9.8'),
          CatalogMediaKind.tv => TvAddDraft(grade: '9.8'),
          CatalogMediaKind.unknown => initialDraft,
        };

        final metadataItem = testCatalogItemWithKindMetadata(item);
        final selectedTarget = CatalogEntityRef(
          kind: kind,
          entityType: const CatalogEntityTypeId('edition'),
          id: 'edition-${kind.apiValue}',
          rootId: item.id,
        );
        final command = addCap.buildCommand(
          LibraryAddCatalogTransport.fromItem(metadataItem),
          common,
          typedDraft,
          targetRef: catalogRefForLibrarySelection(
            metadataItem.catalogRef,
            editionId: selectedTarget.entityType.apiValue == 'edition'
                ? selectedTarget.id
                : null,
            variantId: selectedTarget.entityType.apiValue == 'release'
                ? selectedTarget.id
                : null,
          ),
          tracking: const LibraryAddTrackingDraft(rating: 9),
        );
        expect(command.catalogRef.id, item.id);
        expect(command.targetRef?.id, 'edition-${kind.apiValue}');
        expect(command.tracking?.rating, 9);
        expect(command.tracking?.notes, isNull);
        expect(command.typedPayload, isNotNull,
            reason: '$kind must build a kind-owned Owned create payload');
        expect(command.typedPayload.catalogRef.kind.apiValue, kind.apiValue,
            reason: '$kind payload must retain its owning kind');
        expect(runtime.edit.ownedIndexUpdatePayloadBuilder, isNotNull,
            reason: '$kind must build a kind-owned Owned index payload');
        expect(runtime.edit.ownedConditionValueUpdatePayloadBuilder, isNotNull,
            reason: '$kind must build a kind-owned condition/grade payload');
        expect(runtime.edit.ownedBulkUpdatePayloadBuilder, isNotNull,
            reason: '$kind must build a kind-owned bulk payload');
        expect(runtime.edit.ownedPersonalDetailsUpdatePayloadBuilder, isNotNull,
            reason: '$kind must build a kind-owned personal payload');
        expect(runtime.edit.ownedTransferUpdatePayloadBuilder, isNotNull,
            reason: '$kind must build a kind-owned transfer payload');

        final existing = command.typedPayload.toOwnedItem(
          resolvedCatalogRef: command.catalogRef,
          id: 'existing-${kind.apiValue}',
          createdAt: DateTime.utc(2026, 1, 1),
          existingIsDigital: metadataItem.physicalFormat == 'digital',
          ownerUserId: null,
          ownerLabel: null,
        );
        final duplicatePayload = collectarrOwnedCreatePayloadFromTyped(
          kind,
          existing,
        );
        expect(duplicatePayload.catalogRef.kind,
            command.typedPayload.catalogRef.kind,
            reason: '$kind must support typed Owned duplication');
        expect(
            duplicatePayload.catalogRef.id, command.typedPayload.catalogRef.id,
            reason: '$kind duplication must preserve its catalog target');
        final duplicatedOwned = duplicatePayload.toOwnedItem(
          resolvedCatalogRef: duplicatePayload.catalogRef,
          id: 'duplicate-${kind.apiValue}',
          createdAt: DateTime.utc(2026, 1, 2),
          existingIsDigital: metadataItem.physicalFormat == 'digital',
          ownerUserId: null,
          ownerLabel: null,
        );
        _expectDuplicatedOwnedFields(duplicatedOwned);
        expect(command.typedPayload.detailsDraft,
            isNot(isA<TestOwnedDetailsDraft>()),
            reason: '$kind command details must not be TestOwnedDetailsDraft');

        expect(
          command.typedPayload.detailsDraft.runtimeType,
          expectedOwnedDetailsDraftTypes[kind],
          reason: '$kind must expose its concrete owned details draft type',
        );
      }
    });

    test(
        'no supported kind resolves to unknown or generic fallback in registry',
        () {
      for (final kind in activeKinds) {
        final runtime = testKindModule(kind);
        expect(runtime.kind, isNot(CatalogMediaKind.unknown));
        expect(runtime.add.kind, isNot(CatalogMediaKind.unknown));
      }
    });

    test('all kinds own Add release and format presentation', () {
      for (final kind in activeKinds) {
        final module = testKindModule(kind);
        final item = LibraryAddCatalogTransport.fromItem(
          testCatalogItem(
            id: '${kind.apiValue}-format-test',
            kind: kind.apiValue,
            editions: const [
              CatalogEditionDto(
                id: 'edition-1',
                title: 'Primary edition',
                physicalFormat: 'format-one',
                physicalFormatLabel: 'Format One',
              ),
              CatalogEditionDto(
                id: 'edition-2',
                title: 'Duplicate format edition',
                physicalFormat: 'format-one',
                physicalFormatLabel: 'Format One',
              ),
            ],
          ),
        );

        expect(
          module.presentation.builder.buildReleaseEditions(item: item),
          hasLength(2),
          reason: '$kind must own Add release selection data',
        );
        expect(
          module.presentation.builder.buildAddPreviewFormatBadges(item: item),
          [("format-one", "Format One")],
          reason: '$kind must own Add format badge semantics',
        );
      }
    });

    testWidgets('ComicAddManualPane uses standard visual primitives',
        (tester) async {
      final comicRuntime = testKindModule(CatalogMediaKind.comic);
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
