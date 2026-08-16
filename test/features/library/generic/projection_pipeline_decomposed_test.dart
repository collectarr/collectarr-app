import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Decomposed Projection Pipeline Parity & Performance Tests', () {
    late LibraryTypeConfig comicType;
    late final comicModule = libraryKindRuntimeForKind(CatalogMediaKind.comic);

    setUp(() {
      comicType = comicModule.type;
    });

    LibraryProjectionItem createTestProjectionItem({
      required String id,
      required String title,
      String? seriesTitle,
      String? itemNumber,
      String? publisher,
      String? barcode,
      String? variant,
      bool isOwned = true,
      bool isWishlisted = false,
      int? pricePaidCents,
      int? coverPriceCents,
      int? sellPriceCents,
      DateTime? releaseDate,
    }) {
      final owned = isOwned
          ? OwnedItem(
              id: 'owned-$id',
              updatedAt: DateTime.utc(2026, 1, 1),
              pricePaidCents: pricePaidCents,
              sellPriceCents: sellPriceCents,
              currency: 'USD',
              details: coverPriceCents != null
                  ? ComicOwnedDetails(coverPriceCents: coverPriceCents)
                  : const ComicOwnedDetails(),
              catalogRef: CatalogEntityRef(
                kind: 'comic',
                entityType: CatalogEntityType.ownedCopy,
                id: id,
              ),
            )
          : null;

      final wishlist = isWishlisted
          ? WishlistItem(
              id: 'wish-$id',
              catalogRef: CatalogEntityRef(
                kind: 'comic',
                entityType: CatalogEntityType.issue,
                id: id,
              ),
              createdAt: DateTime.utc(2026, 1, 1),
              updatedAt: DateTime.utc(2026, 1, 1),
            )
          : null;

      final catalog = testCatalogItem(
        id: id,
        kind: 'comic',
        title: title,
        series: seriesTitle != null
            ? CatalogSeriesDetails(seriesTitle: seriesTitle)
            : null,
        itemNumber: itemNumber,
        publisher: publisher ?? 'Marvel',
        barcode: barcode,
        variant: variant,
        releaseDate: releaseDate,
      );

      final shelf = ShelfEntry(
        itemId: id,
        catalogItem: LibraryMetadataItem.fromCatalogItem(catalog),
        ownedItem: owned,
        wishlistItem: wishlist,
      );

      final node = LibraryTitleNodeRef(titleItemId: id);
      final dto = comicModule.projector.projectTitle(
        source: shelf,
        node: node,
      );

      return LibraryProjectionItem(
        source: shelf,
        node: node,
        dto: dto,
      );
    }

    test('LibrarySearchIndex supports multi-field search and caching', () {
      final searchIndex = LibrarySearchIndex();
      final item = createTestProjectionItem(
        id: 'c1',
        title: 'Amazing Spider-Man',
        seriesTitle: 'Spider-Man Vol 1',
        itemNumber: '300',
        publisher: 'Marvel Comics',
        barcode: '759606082974',
        variant: 'Direct Edition',
      );

      final doc = searchIndex.getOrBuild(item, {
        'owned-c1': ['Box 42', 'First Print'],
      });

      // Matches across various metadata fields
      expect(doc.matches('amazing'), isTrue);
      expect(doc.matches('spider-man vol 1'), isTrue);
      expect(doc.matches('300'), isTrue);
      expect(doc.matches('marvel'), isTrue);
      expect(doc.matches('759606082974'), isTrue);
      expect(doc.matches('direct edition'), isTrue);
      expect(doc.matches('box 42'), isTrue);
      expect(doc.matches('batman'), isFalse);

      // Verify cached
      final doc2 = searchIndex.getOrBuild(item);
      expect(identical(doc, doc2), isTrue);
    });

    test(
        'LibraryProjectionIndex caches group bucket and prevents redundant extractor calls',
        () {
      final index = LibraryProjectionIndex();
      final item = createTestProjectionItem(
        id: 'c1',
        title: 'Spider-Man #1',
        publisher: 'Marvel Comics',
      );

      expect(index.extractorCallCount, 0);

      final bucket1 = index.getGroupBucket(
        item,
        'publisher',
        (it, mode) => it.dto.publisher ?? 'Unknown',
      );
      expect(bucket1, 'Marvel Comics');
      expect(index.extractorCallCount, 1);

      // Calling again for same item and groupMode must hit cache and NOT increment count
      final bucket2 = index.getGroupBucket(
        item,
        'publisher',
        (it, mode) => it.dto.publisher ?? 'Unknown',
      );
      expect(bucket2, 'Marvel Comics');
      expect(index.extractorCallCount, 1);

      // Different groupMode evaluates extractor once
      final bucket3 = index.getGroupBucket(
        item,
        'series',
        (it, mode) => 'Series Spider-Man',
      );
      expect(bucket3, 'Series Spider-Man');
      expect(index.extractorCallCount, 2);
    });

    test('LibraryGroupingEngine calculates buckets and gap analysis', () {
      const groupingEngine = LibraryGroupingEngine();
      final items = [
        createTestProjectionItem(
            id: '1',
            title: 'Issue 1',
            seriesTitle: 'X-Men',
            itemNumber: '1',
            publisher: 'Marvel'),
        createTestProjectionItem(
            id: '2',
            title: 'Issue 2',
            seriesTitle: 'X-Men',
            itemNumber: '2',
            publisher: 'Marvel'),
        createTestProjectionItem(
            id: '3',
            title: 'Issue 3',
            seriesTitle: 'X-Men',
            itemNumber: '3',
            publisher: 'Marvel',
            isOwned: false),
        createTestProjectionItem(
            id: '4',
            title: 'Issue 4',
            seriesTitle: 'X-Men',
            itemNumber: '4',
            publisher: 'Marvel'),
        createTestProjectionItem(
            id: '5',
            title: 'Issue 5',
            seriesTitle: 'X-Men',
            itemNumber: '5',
            publisher: 'Marvel'),
      ];

      final buckets = groupingEngine.buildBuckets(items, comicType, 'series');
      expect(buckets.isNotEmpty, isTrue);

      final xmenBucket = buckets.firstWhere((b) => b.title.contains('X-Men'));
      expect(xmenBucket.count, 5);
      expect(xmenBucket.ownedCount, 4);
      expect(xmenBucket.missingNumbers, [3]);
    });

    test('LibraryFolderTreeBuilder builds full tree hierarchy', () {
      const builder = LibraryFolderTreeBuilder();
      final index = LibraryProjectionIndex();
      final items = [
        createTestProjectionItem(
          id: '1',
          title: 'Spider-Man #1',
          seriesTitle: 'Spider-Man',
          publisher: 'Marvel',
        ),
        createTestProjectionItem(
          id: '2',
          title: 'Batman #1',
          seriesTitle: 'Batman',
          publisher: 'DC Comics',
        ),
      ];

      final preset = LibraryFolderPreset(modes: ['publisher', 'series']);
      final tree = builder.buildTree(
        items: items,
        type: comicType,
        preset: preset,
        index: index,
      );

      expect(tree.length, 1); // root node
      expect(tree.first.id, 'root');
      expect(tree.first.count, 2);
      expect(tree.first.children.length, 2); // Marvel and DC
    });

    test('LibrarySeriesGapAnalyzer computes gaps accurately', () {
      const analyzer = LibrarySeriesGapAnalyzer();
      final gaps1 = analyzer.calculateMissingIssues(
        ownedIssues: [1, 2, 4, 5, 8],
        maxIssue: 8,
      );
      expect(gaps1, [3, 6, 7]);

      final gaps2 = analyzer.calculateGapsForBucket(
        ownedNumbers: {1, 2, 5},
        bucketNumbers: {1, 2, 3, 4, 5},
      );
      expect(gaps2, [3, 4]);
    });

    test('LibraryToolbarStatsCalculator calculates counts and financial sums',
        () {
      const calculator = LibraryToolbarStatsCalculator();
      final items = [
        createTestProjectionItem(
          id: '1',
          title: 'Item 1',
          isOwned: true,
          pricePaidCents: 500,
          coverPriceCents: 399,
          sellPriceCents: 1000,
        ),
        createTestProjectionItem(
          id: '2',
          title: 'Item 2',
          isOwned: true,
          pricePaidCents: 400,
          coverPriceCents: 299,
          sellPriceCents: 800,
        ),
        createTestProjectionItem(
          id: '3',
          title: 'Item 3',
          isOwned: false,
          isWishlisted: true,
        ),
      ];

      final stats = calculator.calculate(
        allItems: items,
        shownCount: 2,
      );

      expect(stats.total, 3);
      expect(stats.shown, 2);
      expect(stats.owned, 2);
      expect(stats.wishlist, 1);
      expect(stats.totalPricePaidCents, 900);
      expect(stats.totalCoverPriceCents, 698);
      expect(stats.totalSellPriceCents, 1800);
      expect(stats.priceCurrency, 'USD');
    });

    test('LibraryProjectionEngine executes end-to-end projection cleanly', () {
      final engine = LibraryProjectionEngine();
      final items = [
        createTestProjectionItem(
          id: '1',
          title: 'Amazing Spider-Man #1',
          seriesTitle: 'Amazing Spider-Man',
          publisher: 'Marvel',
        ),
        createTestProjectionItem(
          id: '2',
          title: 'Batman #1',
          seriesTitle: 'Batman',
          publisher: 'DC',
        ),
      ];

      final shelf = ShelfState(
        entries: [
          for (final it in items) it.source,
        ],
        ownedCount: 2,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: 'USD',
        hasMixedCurrencies: false,
      );

      final projection = engine.execute(
        shelf: shelf,
        type: comicType,
        adapter: comicModule.mediaAdapter,
        viewState: LibraryWorkspaceViewState(
          viewMode: LibraryViewMode.grid,
          detailsLayout: LibraryDetailsLayout.hidden,
          isSidebarVisible: true,
          sortColumn: 'title',
          sortAscending: true,
          coverSize: 128,
          sidebarWidth: 200,
          detailsWidth: 300,
          detailsHeight: 220,
          visibleColumns: const {},
          columnWidths: const {},
        ),
        query: const LibraryProjectionQuery(
          searchQuery: 'Spider',
          groupMode: 'publisher',
        ),
      );

      expect(projection.allItems.length, 2);
      expect(projection.filteredItems.length, 1);
      expect(projection.filteredItems.first.dto.title, 'Amazing Spider-Man #1');
      expect(projection.counts.shown, 1);
      expect(projection.counts.total, 2);
      expect(projection.buckets.isNotEmpty, isTrue);
    });
  });
}
