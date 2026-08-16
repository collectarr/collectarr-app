import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

void main() {
  group('Decomposed Projection Pipeline Tests', () {
    test('LibrarySearchIndex normalizes text once per item', () {
      final index = LibrarySearchIndex();
      var supplierCalls = 0;
      final source = ShelfEntry(
        itemId: '1',
        ownedItem: OwnedItem(
          id: 'item-1',
          updatedAt: DateTime(2026),
          catalogRef: const CatalogEntityRef(
            kind: 'comic',
            entityType: CatalogEntityType.ownedCopy,
            id: '1',
          ),
        ),
      );
      final item = LibraryProjectionItem(
        source: source,
        node: const LibraryTitleNodeRef(titleItemId: '1'),
        dto: GenericWorkspaceDto(
          common: const WorkspaceCommonProjection(title: 'Spider-Man #1'),
          personal: PersonalCopyProjection(
            isOwned: true,
            isWishlisted: false,
            isTracked: false,
            updatedAt: DateTime(2026),
          ),
        ),
      );

      final doc1 = index.getOrBuild(item, () {
        supplierCalls++;
        return 'Spider-Man #1';
      });

      expect(doc1.normalizedText, 'spider-man #1');
      expect(supplierCalls, 1);

      // Second call uses cached document
      final doc2 = index.getOrBuild(item, () {
        supplierCalls++;
        return 'Spider-Man #1';
      });

      expect(doc2, same(doc1));
      expect(supplierCalls, 1);
    });

    test(
        'LibraryProjectionIndex caches group values without redundant extractor calls',
        () {
      final index = LibraryProjectionIndex();
      final source = ShelfEntry(
        itemId: '2',
        ownedItem: OwnedItem(
          id: 'item-2',
          updatedAt: DateTime(2026),
          catalogRef: const CatalogEntityRef(
            kind: 'comic',
            entityType: CatalogEntityType.ownedCopy,
            id: '2',
          ),
        ),
      );
      final item = LibraryProjectionItem(
        source: source,
        node: const LibraryTitleNodeRef(titleItemId: '2'),
        dto: GenericWorkspaceDto(
          common: const WorkspaceCommonProjection(title: 'Batman #1'),
          personal: PersonalCopyProjection(
            isOwned: true,
            isWishlisted: false,
            isTracked: false,
            updatedAt: DateTime(2026),
          ),
        ),
      );

      final bucket1 =
          index.getGroupBucket(item, 'publisher', (item, mode) => 'DC Comics');
      expect(bucket1, 'DC Comics');
      expect(index.extractorCallCount, 1);

      // Second query for same item & groupMode hits index cache
      final bucket2 =
          index.getGroupBucket(item, 'publisher', (item, mode) => 'DC Comics');
      expect(bucket2, 'DC Comics');
      expect(index.extractorCallCount, 1);
    });

    test('LibrarySeriesGapAnalyzer identifies missing issues accurately', () {
      const analyzer = LibrarySeriesGapAnalyzer();
      final gaps = analyzer.calculateMissingIssues(
        ownedIssues: [1, 2, 4, 5, 7],
        maxIssue: 7,
      );

      expect(gaps, [3, 6]);
    });

    test('LibraryToolbarStatsCalculator calculates totals correctly', () {
      const calculator = LibraryToolbarStatsCalculator();
      final counts = calculator.calculate(totalAllItems: 150, shownCount: 42);

      expect(counts.total, 150);
      expect(counts.shown, 42);
    });

    test('LibraryFolderTreeBuilder creates tree nodes from projection index',
        () {
      const builder = LibraryFolderTreeBuilder();
      final index = LibraryProjectionIndex();
      final source = ShelfEntry(
        itemId: '3',
        ownedItem: OwnedItem(
          id: 'item-3',
          updatedAt: DateTime(2026),
          catalogRef: const CatalogEntityRef(
            kind: 'comic',
            entityType: CatalogEntityType.ownedCopy,
            id: '3',
          ),
        ),
      );
      final item = LibraryProjectionItem(
        source: source,
        node: const LibraryTitleNodeRef(titleItemId: '3'),
        dto: GenericWorkspaceDto(
          common: const WorkspaceCommonProjection(title: 'Item 3'),
          personal: PersonalCopyProjection(
            isOwned: true,
            isWishlisted: false,
            isTracked: false,
            updatedAt: DateTime(2026),
          ),
        ),
      );

      final preset = LibraryFolderPreset.single('publisher');
      final nodes = builder.buildTree(
        presets: [preset],
        items: [item],
        index: index,
        expandedNodeIds: const {},
      );

      expect(nodes.length, 1);
      expect(nodes.first.groupMode, 'publisher');
      expect(nodes.first.count, 1);
    });
  });
}
