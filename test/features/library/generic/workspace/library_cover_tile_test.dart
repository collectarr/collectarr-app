import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_factories.dart';

void main() {
  testWidgets('cover tile renders cover overlays and remains tappable',
      (tester) async {
    var tapped = false;
    final source = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Superman, Vol. 4',
        itemNumber: '8A',
      ),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        collectionStatus: 'for_sale',
      ),
      wishlistItem: testWishlistItem(id: 'wish-1', itemId: 'comic-1'),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
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
    final source = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Sen to Chihiro no Kamikakushi',
        displayTitle: 'Spirited Away',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
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
    final source = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Spirited Away',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
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
    final source = ShelfEntry(
      itemId: 'music-1',
      catalogItem: testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Lupus Dei',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'music-1');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
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
    final source = ShelfEntry(
      itemId: 'music-2',
      catalogItem: testCatalogItem(
        id: 'music-2',
        kind: 'music',
        title: 'Bible of the Beast',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'music-2');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
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
    final source = ShelfEntry(
      itemId: 'music-3',
      catalogItem: testCatalogItem(
        id: 'music-3',
        kind: 'music',
        title: 'Gods of War',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'music-3');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
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
    final source = ShelfEntry(
      itemId: 'movie-3',
      catalogItem: testCatalogItem(
        id: 'movie-3',
        kind: 'movie',
        title: 'Interstellar',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'movie-3');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
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
