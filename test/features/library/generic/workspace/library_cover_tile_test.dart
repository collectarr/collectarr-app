import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
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
    final source = LibraryWorkspaceSource(
      itemId: 'comic-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Superman, Vol. 4',
        itemNumber: '8A',
      ).asShelfCatalogItem),
      ownedSummary: testOwnedSummary(testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        collectionStatus: 'for_sale',
      )),
      wishlistItem: testWishlistItem(id: 'wish-1', itemId: 'comic-1'),
    );
    const node = LibraryWorkRef(workId: 'comic-1');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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
    expect(find.byTooltip('In collection'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('cover tile hides secondary metadata labels in covers mode',
      (tester) async {
    final source = LibraryWorkspaceSource(
      itemId: 'movie-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Sen to Chihiro no Kamikakushi',
        displayTitle: 'Spirited Away',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'movie-1');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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

    expect(find.text('Sen to Chihiro no Kamikakushi'), findsOneWidget);
    expect(find.text('movie-1'), findsNothing);
  });

  testWidgets('cover tile shows hover selection affordance and edit action',
      (tester) async {
    var editTapped = false;
    final source = LibraryWorkspaceSource(
      itemId: 'movie-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Spirited Away',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'movie-1');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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

  testWidgets('cover tile keeps edit action visible over auxiliary badges',
      (tester) async {
    final source = LibraryWorkspaceSource(
      itemId: 'movie-hover-badges-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-hover-badges-1',
        kind: 'movie',
        title: 'Spirited Away',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'movie-hover-badges-1');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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
                onEditTap: () {},
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

    final badgeCenter = tester.getCenter(
      find.byIcon(Icons.image_not_supported_outlined),
    );
    await hover.moveTo(badgeCenter);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Edit item'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active inspection state does not show checked selection',
      (tester) async {
    final source = LibraryWorkspaceSource(
      itemId: 'music-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Lupus Dei',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'music-1');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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
    final source = LibraryWorkspaceSource(
      itemId: 'music-2',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'music-2',
        kind: 'music',
        title: 'Bible of the Beast',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'music-2');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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
    final source = LibraryWorkspaceSource(
      itemId: 'music-3',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'music-3',
        kind: 'music',
        title: 'Gods of War',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'music-3');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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
    final toggleCenter =
        tester.getCenter(find.byType(LibraryTileSelectionToggle));
    await gesture.down(toggleCenter);
    await gesture.moveBy(const Offset(80, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(toggleTapped, isTrue);
  });

  testWidgets('edit action fires on mouse down even when pointer leaves button',
      (tester) async {
    var editTapped = false;
    final source = LibraryWorkspaceSource(
      itemId: 'movie-3',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-3',
        kind: 'movie',
        title: 'Interstellar',
      ).asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'movie-3');
    final dto = const GenericWorkspaceProjector().project(
      source: source,
      entity: node,
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
