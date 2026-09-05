import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_custom_tab_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/stats/comic_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/value/comic_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Comic stats count only owned key comics', () {
    final entries = [
      testShelfEntry(
        itemId: 'comic-1',
        ownedItem: testOwnedItem(
          itemId: 'comic-1',
          keyComic: true,
          kind: 'comic',
        ),
      ),
      testShelfEntry(
        itemId: 'comic-2',
        ownedItem: testOwnedItem(itemId: 'comic-2', kind: 'comic'),
      ),
      testShelfEntry(
        itemId: 'comic-3',
        ownedItem: null,
      ),
    ];

    expect(ComicStatsCapability.countKeyComics(entries), 1);
  });

  test('Comic value capability summarizes cover prices and currencies', () {
    final entries = [
      testShelfEntry(
        itemId: 'comic-1',
        ownedItem: testOwnedItem(
          itemId: 'comic-1',
          kind: 'comic',
          coverPriceCents: 1200,
          currency: 'USD',
        ),
      ),
      testShelfEntry(
        itemId: 'comic-2',
        ownedItem: testOwnedItem(
          itemId: 'comic-2',
          kind: 'comic',
          coverPriceCents: 800,
          currency: 'USD',
        ),
      ),
      testShelfEntry(
        itemId: 'comic-3',
        ownedItem: testOwnedItem(
          itemId: 'comic-3',
          kind: 'comic',
          coverPriceCents: 500,
        ),
      ),
    ];

    final summary =
        const ComicValueCapability().resolveCollectionValueSummary(entries);

    expect(summary?.valuedCount, 2);
    expect(summary?.totalValueCents, 2000);
    expect(summary?.currency, 'USD');
    expect(summary?.hasMixedCurrencies, isFalse);
  });

  test('Comic hierarchy diagnostics are owned by the Comic module', () {
    final complete = _comicProjection(
      id: 'complete',
      seriesTitle: 'Saga',
      variant: 'A',
    );
    final missingSeries = _comicProjection(id: 'missing-series');
    final missingVariant = _comicProjection(
      id: 'missing-variant',
      seriesTitle: 'Saga',
      node: const LibraryCopyNodeRef(
          titleItemId: 'missing-variant', ownedItemId: 'owned-missing-variant'),
    );

    expect(libraryHierarchyContractDiagnosticLabel(complete), isNull);
    expect(
      libraryHierarchyContractDiagnosticLabel(missingSeries),
      'Missing series title',
    );
    expect(
      libraryHierarchyContractDiagnosticLabel(missingVariant),
      'Missing release variant',
    );
  });

  test('Comic owns its cover-price transfer field', () {
    expect(kTransferableReleaseFieldKeys, isNot(contains('coverPriceCents')));
    expect(
      comicKindModule.transfer.fieldKeysForScope(LibraryEditScope.release),
      contains('coverPriceCents'),
    );
  });

  testWidgets('Comic media editing uses the typed edit schema', (tester) async {
    final item = typedCatalogItemFromCatalogItem(
      testCatalogItem(
        id: 'comic-media-editor',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Saga'),
      ),
    );
    final request = LibraryEditDialogRequest(
      type: comicKindModule,
      item: item,
      ownedItem: null,
      accent: Colors.blue,
      scope: LibraryEditScope.media,
    );
    final builder = comicKindModule.edit.mediaEditDialogBuilder;

    expect(builder, isNotNull);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => builder!(context, request),
          ),
        ),
      ),
    );

    expect(find.text('Issue'), findsOneWidget);
    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Issue number'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Comic release editing uses the typed edit schema',
      (tester) async {
    final item = typedCatalogItemFromCatalogItem(
      testCatalogItem(
        id: 'comic-release-editor',
        kind: 'comic',
        title: 'Saga #1',
        editions: const [
          CatalogEditionDto(
            id: 'release-1',
            title: 'Direct Market Edition',
            publisher: 'Image',
          ),
        ],
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Saga'),
      ),
    );
    final request = LibraryEditDialogRequest(
      type: comicKindModule,
      item: item,
      ownedItem: null,
      accent: Colors.blue,
      scope: LibraryEditScope.release,
    );
    final builder = comicKindModule.edit.releaseEditDialogBuilder;

    expect(builder, isNotNull);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => builder!(context, request),
          ),
        ),
      ),
    );

    expect(find.text('Edition title'), findsOneWidget);
    expect(find.text('Publisher'), findsOneWidget);
    expect(find.text('ISBN'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Comic owned editing uses the typed edit schema tab',
      (tester) async {
    final item = typedCatalogItemFromCatalogItem(
      testCatalogItem(
        id: 'comic-owned-editor',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Saga'),
      ),
    );
    final request = LibraryEditDialogRequest(
      type: comicKindModule,
      item: item,
      ownedItem: testOwnedItem(
        itemId: item.identity.id,
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        keyComic: true,
        keyReason: 'First appearance',
        coverPriceCents: 2500,
      ),
      accent: Colors.blue,
    );
    final draft = LibraryEditDraft.fromRequest(request);
    addTearDown(draft.dispose);

    final ownedTabs = comicKindModule.edit.presentation.builder.buildTabs(
      context: const LibraryEditPresentationContext(
        isOwned: true,
        isTrackingOnly: false,
        hasTrackingContext: true,
        hasWishlistContext: false,
        isDigitalFormat: false,
        hasPhysicalFormats: true,
        hasEditionAnchors: false,
        hasBundleReleaseAnchors: false,
        hasCustomFields: false,
        scope: LibraryEditScope.all,
      ),
    );
    expect(ownedTabs.map((tab) => tab.id), contains('owned'));

    late Widget ownedTab;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ownedTab = buildComicCustomTabView(
                tabId: 'owned',
                context: context,
                draft: draft,
                accent: Colors.blue,
                scope: LibraryEditScope.all,
                item: item,
                markDirty: () {},
              )!;
              return ownedTab;
            },
          ),
        ),
      ),
    );

    expect(find.text('Raw / Slabbed'), findsOneWidget);
    expect(find.text('Grading company'), findsOneWidget);
    expect(find.text('Key comic'), findsNWidgets(2));
    expect(find.text('Cover price'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
}

LibraryProjectionItem<ComicWorkspaceDto> _comicProjection({
  required String id,
  String? seriesTitle,
  String? variant,
  LibraryNodeRef? node,
}) {
  final source = testShelfEntry(
    itemId: id,
    catalogItem: testCatalogItem(
      id: id,
      kind: 'comic',
      series: seriesTitle == null
          ? null
          : CatalogSeriesDetailsDto(seriesTitle: seriesTitle),
      variant: variant,
    ),
  );
  final titleNode = LibraryTitleNodeRef(titleItemId: id);
  final dto = comicKindModule.projector.projectTitle(
    source: source,
    node: titleNode,
  );
  return LibraryProjectionItem(
    source: source,
    node: node ?? titleNode,
    dto: dto,
  );
}
