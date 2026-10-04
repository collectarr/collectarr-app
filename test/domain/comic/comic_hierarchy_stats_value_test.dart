import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_custom_tab_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/stats/comic_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/value/comic_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Comic stats count only entry key comics', () {
    final entries = [
      testLibraryWorkspaceSource(
        itemId: 'comic-1',
        libraryEntry: testLibraryEntry(
          itemId: 'comic-1',
          keyComic: true,
          kind: 'comic',
        ),
      ),
      testLibraryWorkspaceSource(
        itemId: 'comic-2',
        libraryEntry: testLibraryEntry(itemId: 'comic-2', kind: 'comic'),
      ),
      testLibraryWorkspaceSource(
        itemId: 'comic-3',
        libraryEntry: null,
      ),
    ];

    expect(ComicStatsCapability.countKeyComics(entries), 1);
  });

  test('Comic value capability summarizes cover prices and currencies', () {
    final entries = [
      testLibraryWorkspaceSource(
        itemId: 'comic-1',
        libraryEntry: testLibraryEntry(
          itemId: 'comic-1',
          kind: 'comic',
          coverPriceCents: 1200,
          currency: 'USD',
        ),
      ),
      testLibraryWorkspaceSource(
        itemId: 'comic-2',
        libraryEntry: testLibraryEntry(
          itemId: 'comic-2',
          kind: 'comic',
          coverPriceCents: 800,
          currency: 'USD',
        ),
      ),
      testLibraryWorkspaceSource(
        itemId: 'comic-3',
        libraryEntry: testLibraryEntry(
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

  test('Comic hierarchy diagnostics are entry by the Comic contributor', () {
    final complete = _comicProjection(
      id: 'complete',
      seriesTitle: 'Saga',
      variant: 'A',
    );
    final missingSeries = _comicProjection(id: 'missing-series');
    final missingVariant = _comicProjection(
      id: 'missing-variant',
      seriesTitle: 'Saga',
      node: LibraryEntryNodeRef(
        catalogItemId: 'missing-variant',
        libraryEntryRef: const LibraryEntryRef(
          kind: CatalogMediaKind.comic,
          id: LibraryEntryId('entry-missing-variant'),
        ),
      ),
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
      comicKindTransfer.fieldKeysForScope(LibraryEntityScope.libraryEntry),
      contains('coverPriceCents'),
    );
  });

  testWidgets('Comic media editing uses the typed edit schema', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = testCatalogItemWithKindMetadata(
      testCatalogItem(
        id: 'comic-media-editor',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Saga'),
      ),
    );
    final request = LibraryEditDialogRequest(
      type: const ComicRegistration(),
      item: CatalogSearchCandidate.fromItem(item),
      libraryEntry: null,
      accent: Colors.blue,
      scope: LibraryEntityScope.libraryEntry,
    );
    final builder = comicKindEditCapabilities
        .presentationCapability.editRegistry
        .builderForScope(LibraryEntityScope.libraryEntry);

    expect(builder, isNotNull);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => builder!(context, request),
            ),
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
    final item = testCatalogItemWithKindMetadata(
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
      type: const ComicRegistration(),
      item: CatalogSearchCandidate.fromItem(item),
      libraryEntry: null,
      accent: Colors.blue,
      scope: LibraryEntityScope.release,
      editPrimaryRelease: true,
    );
    final builder = comicKindEditCapabilities
        .presentationCapability.editRegistry
        .builderForScope(LibraryEntityScope.release);

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

  testWidgets('Comic entry editing uses the typed edit schema tab',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = testCatalogItemWithKindMetadata(
      testCatalogItem(
        id: 'comic-entry-editor',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Saga'),
      ),
    );
    final request = LibraryEditDialogRequest(
      type: const ComicRegistration(),
      item: CatalogSearchCandidate.fromItem(item),
      libraryEntry: testLibraryEntrySummary(testLibraryEntry(
        itemId: item.identity.id,
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        keyComic: true,
        keyReason: 'First appearance',
        coverPriceCents: 2500,
      )),
      accent: Colors.blue,
    );
    final draft = LibraryEditShellState.fromRequest(request);
    addTearDown(draft.dispose);

    final entryTabs = comicKindEditCapabilities
        .presentationCapability.presentation.builder
        .buildTabs(
      context: const LibraryEditPresentationContext(
        isEntry: true,
        isTrackingOnly: false,
        hasTrackingContext: true,
        hasWishlistContext: false,
        isDigitalFormat: false,
        hasPhysicalFormats: true,
        hasCustomFields: false,
        scope: LibraryEntityScope.libraryEntry,
      ),
    );
    expect(entryTabs.map((tab) => tab.id), contains('entry'));

    late Widget entryTab;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                entryTab = buildComicCustomTabView(
                  tabId: 'entry',
                  context: context,
                  draft: draft,
                  accent: Colors.blue,
                  scope: LibraryEntityScope.libraryEntry,
                  item: CatalogSearchCandidate.fromItem(item),
                  markDirty: () {},
                )!;
                return entryTab;
              },
            ),
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
  LibraryEntityRef? node,
}) {
  final source = testLibraryWorkspaceSource(
    itemId: id,
    catalogData: testWorkspaceCatalogData(testCatalogItem(
      id: id,
      kind: 'comic',
      series: seriesTitle == null
          ? null
          : CatalogSeriesDetailsDto(seriesTitle: seriesTitle),
      variant: variant,
    )),
  );
  final titleNode = LibraryCatalogItemNodeRef(catalogItemId: id);
  final dto = comicKindWorkspace
      .projectorForScope(LibraryEntityScope.catalogItem)
      .project(
        source: source,
        entity: titleNode,
      );
  return LibraryProjectionItem(
    source: source,
    node: node ?? titleNode,
    dto: dto,
  );
}
