import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_factories.dart';

void main() {
  testWidgets('cover tile renders cover overlays and remains tappable',
      (tester) async {
    var tapped = false;
    final item = const GenericWorkspaceProjector().project(
      source: ShelfEntry(
        catalogItem: const CatalogItemDto(
          id: 'comic-1',
          kind: 'comic',
          title: 'Superman, Vol. 4',
          issueNumber: '8A',
        ),
        ownedItem: testOwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          collectionStatus: 'for_sale',
        ),
        wishlistItem: testWishlistItem(id: 'wish-1', itemId: 'comic-1'),
      ),
      node: const LibraryTitleNodeRef('comic-1'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              item: item,
              active: false,
              selected: true,
              selectionMode: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryCoverTile));

    expect(tapped, isTrue);
    expect(find.byTooltip('For sale'), findsOneWidget);
    expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('cover tile hides secondary metadata labels in covers mode',
      (tester) async {
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'movie-1',
          kind: 'movie',
          title: 'Sen to Chihiro no Kamikakushi',
          displayTitle: 'Spirited Away',
        ),
      ),
      node: const LibraryTitleNodeRef('movie-1'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              item: item,
              active: false,
              selected: false,
              selectionMode: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sen to Chihiro no Kamikakushi'), findsNothing);
    expect(find.text('movie-1'), findsNothing);
  });

  testWidgets('cover tile shows hover selection affordance and edit action',
      (tester) async {
    var editTapped = false;
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'movie-1',
          kind: 'movie',
          title: 'Spirited Away',
        ),
      ),
      node: const LibraryTitleNodeRef('movie-1'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Material(
            child: SizedBox(
              width: 140,
              height: 220,
              child: LibraryCoverTile(
                item: item,
                active: false,
                selected: false,
                selectionMode: false,
                onTap: () {},
                onEditTap: () => editTapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LibraryTileSelectionToggle), findsNothing);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(LibraryCoverTile)));
    await tester.pumpAndSettle();

    expect(find.byType(LibraryTileSelectionToggle), findsOneWidget);
    expect(find.byTooltip('Edit item'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(editTapped, isTrue);
  });

  testWidgets('active inspection state does not show checked selection',
      (tester) async {
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'music-1',
          kind: 'music',
          title: 'Lupus Dei',
        ),
      ),
      node: const LibraryTitleNodeRef('music-1'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              item: item,
              active: true,
              selected: false,
              selectionMode: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
  });

  testWidgets('selection toggle tap does not trigger tile tap', (tester) async {
    var tileTapped = false;
    var toggleTapped = false;
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'music-2',
          kind: 'music',
          title: 'Bible of the Beast',
        ),
      ),
      node: const LibraryTitleNodeRef('music-2'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              item: item,
              active: false,
              selected: false,
              selectionMode: true,
              onTap: () => tileTapped = true,
              onSelectionToggleTap: () => toggleTapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryTileSelectionToggle));
    await tester.pumpAndSettle();

    expect(toggleTapped, isTrue);
    expect(tileTapped, isFalse);
  });

  testWidgets('selection toggle activates on mouse down even if pointer leaves',
      (tester) async {
    var toggleTapped = false;
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'music-3',
          kind: 'music',
          title: 'Gods of War',
        ),
      ),
      node: const LibraryTitleNodeRef('music-3'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              item: item,
              active: false,
              selected: false,
              selectionMode: true,
              onTap: () {},
              onSelectionToggleTap: () => toggleTapped = true,
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    final toggleCenter = tester.getCenter(find.byType(LibraryTileSelectionToggle));
    await gesture.down(toggleCenter);
    await gesture.moveBy(const Offset(80, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(toggleTapped, isTrue);
  });

  testWidgets('edit action fires on mouse down even when pointer leaves button',
      (tester) async {
    var editTapped = false;
    final item = const GenericWorkspaceProjector().project(
      source: const ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'movie-3',
          kind: 'movie',
          title: 'Interstellar',
        ),
      ),
      node: const LibraryTitleNodeRef('movie-3'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Material(
            child: SizedBox(
              width: 140,
              height: 220,
              child: LibraryCoverTile(
                item: item,
                active: false,
                selected: false,
                selectionMode: false,
                onTap: () {},
                onEditTap: () => editTapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    final hover = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await hover.addPointer();
    await hover.moveTo(tester.getCenter(find.byType(LibraryCoverTile)));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Edit item'), findsOneWidget);

    final editCenter = tester.getCenter(find.byIcon(Icons.edit_outlined));
    await hover.moveTo(editCenter);
    await hover.down(editCenter);
    await hover.moveBy(const Offset(80, 0));
    await hover.up();
    await tester.pumpAndSettle();

    expect(editTapped, isTrue);
  });
}
