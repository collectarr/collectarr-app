import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/test/helpers/test_entry_details.dart';
import 'package:collectarr_app/test/helpers/concrete_kind_dispatch.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
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
        final runtime = testKindRegistration(kind);
        expect(runtime, isNotNull,
            reason: '$kind must be registered in LibraryKindRegistry');

        final addCap = libraryAddForKind(kind);
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
          _expectedAddDraftType(kind),
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
          CatalogSearchCandidate.fromItem(metadataItem),
          common,
          typedDraft,
          targetRef: libraryCatalogTargetForKind(kind).resolve(
            metadataItem.catalogRef,
            LibraryCatalogTargetSelection(
              referenceType: LibraryAddReferenceType.edition,
              firstId: selectedTarget.entityType.apiValue == 'edition'
                  ? selectedTarget.id
                  : null,
              secondId: selectedTarget.entityType.apiValue == 'release'
                  ? selectedTarget.id
                  : null,
            ),
          ),
          tracking: const LibraryAddTrackingDraft(rating: 9),
        );
        expect(command.catalogRef.id, item.id);
        expect(command.targetRef?.id, 'edition-${kind.apiValue}');
        expect(command.tracking?.rating, 9);
        expect(command.tracking?.notes, isNull);
        expect(command.typedPayload, isNotNull,
            reason: '$kind must build a kind-entry Entry create payload');
        expect(command.typedPayload.catalogRef.kind.apiValue, kind.apiValue,
            reason: '$kind payload must retain its owning kind');
        expect(libraryEntryEditForKind(kind).entryIndexUpdatePayloadBuilder,
            isNotNull,
            reason: '$kind must build a kind-entry Entry index payload');
        expect(
            libraryEntryEditForKind(kind)
                .entryConditionValueUpdatePayloadBuilder,
            isNotNull,
            reason: '$kind must build a kind-entry condition/grade payload');
        expect(libraryEntryEditForKind(kind).entryBulkUpdatePayloadBuilder,
            isNotNull,
            reason: '$kind must build a kind-entry bulk payload');
        expect(
            libraryEntryEditForKind(kind)
                .entryPersonalDetailsUpdatePayloadBuilder,
            isNotNull,
            reason: '$kind must build a kind-entry personal payload');
        expect(libraryEntryEditForKind(kind).entryTransferUpdatePayloadBuilder,
            isNotNull,
            reason: '$kind must build a kind-entry transfer payload');

        expect(command.typedPayload.detailsDraft,
            isNot(isA<TestEntryDetailsDraft>()),
            reason: '$kind command details must not be TestEntryDetailsDraft');

        expect(
          command.typedPayload.detailsDraft.runtimeType,
          _expectedEntryDetailsDraftType(kind),
          reason: '$kind must expose its concrete entry details draft type',
        );
      }
    });

    test(
        'no supported kind resolves to unknown or generic fallback in registry',
        () {
      for (final kind in activeKinds) {
        final runtime = testKindRegistration(kind);
        expect(runtime.kind, isNot(CatalogMediaKind.unknown));
        expect(libraryAddForKind(kind).kind, isNot(CatalogMediaKind.unknown));
      }
    });

    test('all kinds own Add release and format presentation', () {
      for (final kind in activeKinds) {
        final registration = testKindRegistration(kind);
        final item = CatalogSearchCandidate.fromItem(
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
          libraryPresentationForKind(registration.kind)
              .builder
              .buildReleaseOptions(item: item),
          hasLength(2),
          reason: '$kind must own Add release selection data',
        );
        final badges = libraryPresentationForKind(registration.kind)
            .builder
            .buildAddPreviewFormatBadges(item: item);
        expect(badges, hasLength(1),
            reason: '$kind must own Add format badge semantics');
        expect(badges.single.key, 'format-one');
        expect(badges.single.label, 'Format One');
      }
    });

    testWidgets('ComicAddManualPane uses standard visual primitives',
        (tester) async {
      final draft = libraryAddForKind(CatalogMediaKind.comic)
          .createManualDraft() as ComicAddManualDraft;

      final request = LibraryAddManualPaneRequest(
        kind: CatalogMediaKind.comic,
        accent: Colors.blue,
        type: const ComicRegistration(),
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
        onAddEntry: () {},
        onAddWishlist: () {},
        onAddTrack: () {},
        onPropose: () {},
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

Type _expectedAddDraftType(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.comic => ComicAddDraft,
    CatalogMediaKind.manga => MangaAddDraft,
    CatalogMediaKind.movie => MovieAddDraft,
    CatalogMediaKind.tv => TvAddDraft,
    CatalogMediaKind.anime => AnimeAddDraft,
    CatalogMediaKind.book => BookAddDraft,
    CatalogMediaKind.game => GameAddDraft,
    CatalogMediaKind.boardgame => BoardgameAddDraft,
    CatalogMediaKind.music => MusicAddDraft,
    CatalogMediaKind.unknown => Object,
  };
}

Type _expectedEntryDetailsDraftType(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.comic => ComicEntryDetailsDraft,
    CatalogMediaKind.manga => MangaEntryDetailsDraft,
    CatalogMediaKind.movie => MovieEntryDetailsDraft,
    CatalogMediaKind.tv => TvEntryDetailsDraft,
    CatalogMediaKind.anime => AnimeEntryDetailsDraft,
    CatalogMediaKind.book => BookEntryDetailsDraft,
    CatalogMediaKind.game => GameEntryDetailsDraft,
    CatalogMediaKind.boardgame => BoardgameEntryDetailsDraft,
    CatalogMediaKind.music => MusicEntryDetailsDraft,
    CatalogMediaKind.unknown => Object,
  };
}
