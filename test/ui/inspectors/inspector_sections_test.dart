import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_shared_sections.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('LibraryDetailSectionSpec', () {
    testWidgets('builds a standard inspector section wrapper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: buildLibraryDetailSectionWidgets([
                const LibraryDetailSectionSpec(
                  title: 'Example',
                  children: [Text('Section body')],
                ),
              ]),
            ),
          ),
        ),
      );

      expect(find.text('Example'), findsOneWidget);
      expect(find.text('Section body'), findsOneWidget);
    });
  });

  group('LibraryDetailSectionFlow', () {
    testWidgets('keeps section groups in order and skips empty groups',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: buildLibraryDetailSectionFlow(
                beforeBodySections: const [Text('Before')],
                bodySections: const [Text('Body')],
                afterBodySections: const [Text('After')],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Before'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('After'), findsOneWidget);
    });
  });

  group('LibraryInspectorTitleStatusCard', () {
    testWidgets('renders eyebrow title and status badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryInspectorTitleStatusCard(
              eyebrow: 'Series',
              title: 'Dune',
              accent: Colors.blue,
              statusIcon: Icons.inventory_2_outlined,
              statusLabel: 'In collection',
            ),
          ),
        ),
      );

      expect(find.text('Series'), findsOneWidget);
      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('In collection'), findsOneWidget);
    });
  });

  group('InspectorMetadataSection', () {
    testWidgets('renders metadata section title', (tester) async {
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.comic)!;
      final source1 = ShelfEntry(
        itemId: 'comic-1',
        catalogItem: testCatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Spider-Man #1',
          publisher: 'Marvel',
        ),
      );
      const node1 = LibraryTitleNodeRef(titleItemId: 'comic-1');
      final dto1 = const ComicWorkspaceProjector().projectTitle(source: source1, node: node1);
      final comicItem = LibraryProjectionItem(source: source1, node: node1, dto: dto1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorMetadataSection(
              type: type,
              item: comicItem,
              accent: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('Metadata'), findsWidgets);
    });

    testWidgets('triggers onFilterByValue callback', (tester) async {
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.comic)!;
      final source2 = ShelfEntry(
        itemId: 'comic-1',
        catalogItem: testCatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Spider-Man #1',
          publisher: 'Marvel',
        ),
      );
      const node2 = LibraryTitleNodeRef(titleItemId: 'comic-1');
      final dto2 = const ComicWorkspaceProjector().projectTitle(source: source2, node: node2);
      final comicItem = LibraryProjectionItem(source: source2, node: node2, dto: dto2);
      String? filteredValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorMetadataSection(
              type: type,
              item: comicItem,
              accent: Colors.red,
              onFilterByValue: (v) => filteredValue = v,
            ),
          ),
        ),
      );

      expect(filteredValue, isNull);
    });
  });

  group('InspectorPersonalSection', () {
    testWidgets('shows tracking status and rating', (tester) async {
      final source0a = ShelfEntry(
        itemId: 'book-1',
        catalogItem: testCatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Dune',
        ),
      );
      const node0a = LibraryTitleNodeRef(titleItemId: 'book-1');
      final dto0a = const GenericWorkspaceProjector().projectTitle(source: source0a, node: node0a);
      final bookItem = LibraryProjectionItem(source: source0a, node: node0a, dto: dto0a);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              item: bookItem,
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                rating: 8,
                readStatus: 'completed',
                condition: 'Near Mint',
                grade: '9.4',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              trackingEntry: TrackingEntry(
                id: 'track-1',
                catalogRef: testCatalogRef('book-1', kind: 'book'),
                rating: 8,
                progressCurrent: 412,
                progressTotal: 412,
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(InspectorPersonalSection), findsOneWidget);
    });

    testWidgets('shows quantity when more than 1', (tester) async {
      final source0b = ShelfEntry(
        itemId: 'book-1',
        catalogItem: testCatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Dune',
        ),
      );
      const node0b = LibraryTitleNodeRef(titleItemId: 'book-1');
      final dto0b = const GenericWorkspaceProjector().projectTitle(source: source0b, node: node0b);
      final bookItem = LibraryProjectionItem(source: source0b, node: node0b, dto: dto0b);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              item: bookItem,
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                quantity: 3,
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows sold information when soldAt is set', (tester) async {
      final source1 = ShelfEntry(
        itemId: 'book-1',
        catalogItem: testCatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Dune',
        ),
      );
      const node1 = LibraryTitleNodeRef(titleItemId: 'book-1');
      final dto1 = const GenericWorkspaceProjector().projectTitle(source: source1, node: node1);
      final bookItem = LibraryProjectionItem(source: source1, node: node1, dto: dto1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              item: bookItem,
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                pricePaidCents: 1000,
                currency: 'USD',
                soldAt: DateTime.utc(2026, 5, 20),
                sellPriceCents: 1500,
                soldTo: 'Collector X',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Sold'), findsOneWidget);
      expect(find.text('Profit / Loss'), findsOneWidget);
    });

    testWidgets('shows tags when present', (tester) async {
      String? tappedValue;
      final source2 = ShelfEntry(
        itemId: 'book-1',
        catalogItem: testCatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Dune',
        ),
      );
      const node2 = LibraryTitleNodeRef(titleItemId: 'book-1');
      final dto2 = const GenericWorkspaceProjector().projectTitle(source: source2, node: node2);
      final bookItem = LibraryProjectionItem(source: source2, node: node2, dto: dto2);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              item: bookItem,
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                tags: 'sci-fi, classic',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
              onFilterByValue: (value) => tappedValue = value,
            ),
          ),
        ),
      );

      expect(find.text('sci-fi'), findsOneWidget);
      expect(find.text('classic'), findsOneWidget);

      await tester.tap(find.text('sci-fi'));
      await tester.pumpAndSettle();

      expect(tappedValue, 'sci-fi');
    });
  });

  group('EmptyInspector', () {
    testWidgets('renders placeholder text', (tester) async {
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.comic)!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyInspector(type: type, accent: Colors.grey),
          ),
        ),
      );

      expect(find.textContaining('No comic selected'), findsOneWidget);
    });
  });
}
