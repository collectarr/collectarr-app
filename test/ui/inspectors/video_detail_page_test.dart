import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_launcher.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_constants.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  testWidgets('double tap on a video card opens the release browser',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.movie)!;
    final source1 = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: CatalogItemDto(
        id: 'movie-1',
        kind: 'movie',
        title: 'Sen to Chihiro no Kamikakushi',
        displayTitle: 'Spirited Away',
        originalTitle: 'Sen to Chihiro no Kamikakushi',
        editions: [
          CatalogEditionDto(
            id: 'edition-4k',
            title: '4K Steelbook',
            publisher: 'Studio Ghibli',
            releaseDate: DateTime.utc(2024, 1, 5),
            variants: const [
              CatalogVariantDto(
                id: 'variant-uhd',
                name: '4K UHD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'movie-1',
        editionId: 'edition-4k',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 25, 10),
      ),
    );
    const node1 = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final item = libraryKindRuntimeForKind(CatalogMediaKind.movie)
        .project(source: source1, node: node1);

    final request = LibraryDetailPageRequest(
      type: type,
      item: item,
      ownedItem: null,
      accent: Colors.orange,
      onAddOwned: () {},
      onRemoveOwned: () {},
      onAddWishlist: () {},
      onRemoveWishlist: () {},
      onEdit: (_) {},
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: SizedBox(
                width: 420,
                height: 170,
                child: LibraryWorkspaceCard(
                  item: item,
                  selected: false,
                  onTap: () {},
                  onDoubleTap: () =>
                      showLibraryDetailPage(context: context, request: request),
                  dateFormatter: (value) =>
                      value.toIso8601String().split('T').first,
                  moneyFormatter: (cents, currency) => '$currency $cents',
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.detail,
          builder: (context, state) {
            final detailRequest = state.extra! as LibraryDetailPageRequest;
            final builder = detailRequest.type.detailPageBuilder!;
            return builder(context, detailRequest);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionProvider.overrideWith(
            (ref) async => [
              testOwnedItem(
                id: 'owned-1',
                itemId: 'movie-1',
                editionId: 'edition-4k',
                quantity: 1,
                updatedAt: DateTime.utc(2026, 5, 25, 10),
              ),
            ],
          ),
          wishlistProvider.overrideWith(
            (ref) async => const <WishlistItem>[],
          ),
          watchSessionsByItemProvider.overrideWith(
            (ref) => const <String, List<WatchSession>>{},
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.tap(find.byType(LibraryWorkspaceCard));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(LibraryWorkspaceCard));
    await pumpUntilSettled(tester);

    expect(find.text('Releases'), findsWidgets);
    expect(find.text('4K Steelbook'), findsWidgets);
    expect(find.text('1 copy in collection'), findsWidgets);
    expect(find.text('Add copy'), findsOneWidget);
    expect(find.text('Move to wishlist'), findsOneWidget);
    expect(find.text('Catalog edition'), findsWidgets);
  });

  testWidgets('release browser shows remove wishlist for the selected release',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.movie)!;
    final source2 = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: CatalogItemDto(
        id: 'movie-1',
        kind: 'movie',
        title: 'Sen to Chihiro no Kamikakushi',
        displayTitle: 'Spirited Away',
        originalTitle: 'Sen to Chihiro no Kamikakushi',
        editions: [
          CatalogEditionDto(
            id: 'edition-4k',
            title: '4K Steelbook',
            publisher: 'Studio Ghibli',
            releaseDate: DateTime.utc(2024, 1, 5),
            variants: const [
              CatalogVariantDto(
                id: 'variant-uhd',
                name: '4K UHD',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
      wishlistItem: WishlistItem(
        id: 'wishlist-1',
        catalogRef: const CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.ownedCopy,
          id: 'movie-1',
        ),
        anchorType: 'edition',
        editionId: 'edition-4k',
        createdAt: DateTime.utc(2026, 5, 25, 9),
        updatedAt: DateTime.utc(2026, 5, 25, 10),
      ),
    );
    const node2 = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final item = libraryKindRuntimeForKind(CatalogMediaKind.movie)
        .project(source: source2, node: node2);

    final request = LibraryDetailPageRequest(
      type: type,
      item: item,
      ownedItem: null,
      accent: Colors.orange,
      onAddOwned: () {},
      onRemoveOwned: () {},
      onAddWishlist: () {},
      onRemoveWishlist: () {},
      onEdit: (_) {},
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: SizedBox(
                width: 420,
                height: 170,
                child: LibraryWorkspaceCard(
                  item: item,
                  selected: false,
                  onTap: () {},
                  onDoubleTap: () =>
                      showLibraryDetailPage(context: context, request: request),
                  dateFormatter: (value) =>
                      value.toIso8601String().split('T').first,
                  moneyFormatter: (cents, currency) => '$currency $cents',
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.detail,
          builder: (context, state) {
            final detailRequest = state.extra! as LibraryDetailPageRequest;
            final builder = detailRequest.type.detailPageBuilder!;
            return builder(context, detailRequest);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionProvider.overrideWith(
            (ref) async => const <OwnedItem>[],
          ),
          wishlistProvider.overrideWith(
            (ref) async => [
              WishlistItem(
                id: 'wishlist-1',
                catalogRef: const CatalogEntityRef(
                  kind: 'movie',
                  entityType: CatalogEntityType.ownedCopy,
                  id: 'movie-1',
                ),
                anchorType: 'edition',
                editionId: 'edition-4k',
                createdAt: DateTime.utc(2026, 5, 25, 9),
                updatedAt: DateTime.utc(2026, 5, 25, 10),
              ),
            ],
          ),
          watchSessionsByItemProvider.overrideWith(
            (ref) => const <String, List<WatchSession>>{},
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.tap(find.byType(LibraryWorkspaceCard));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(LibraryWorkspaceCard));
    await pumpUntilSettled(tester);

    expect(find.text('Remove wishlist'), findsOneWidget);
    expect(find.text('Move to wishlist'), findsNothing);
  });

  testWidgets('release browser explains when core has no releases yet',
      (tester) async {
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.movie)!;
    final source3 = ShelfEntry(
      itemId: 'movie-2',
      catalogItem: testCatalogItem(
        id: 'movie-2',
        kind: 'movie',
        title: 'Castle in the Sky',
        displayTitle: 'Castle in the Sky',
      ),
    );
    const node3 = LibraryTitleNodeRef(titleItemId: 'movie-2');
    final item = libraryKindRuntimeForKind(CatalogMediaKind.movie)
        .project(source: source3, node: node3);

    final request = LibraryDetailPageRequest(
      type: type,
      item: item,
      ownedItem: null,
      accent: Colors.orange,
      onAddOwned: () {},
      onRemoveOwned: () {},
      onAddWishlist: () {},
      onRemoveWishlist: () {},
      onEdit: (_) {},
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: SizedBox(
                width: 420,
                height: 170,
                child: LibraryWorkspaceCard(
                  item: item,
                  selected: false,
                  onTap: () {},
                  onDoubleTap: () =>
                      showLibraryDetailPage(context: context, request: request),
                  dateFormatter: (value) =>
                      value.toIso8601String().split('T').first,
                  moneyFormatter: (cents, currency) => '$currency $cents',
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.detail,
          builder: (context, state) {
            final detailRequest = state.extra! as LibraryDetailPageRequest;
            final builder = detailRequest.type.detailPageBuilder!;
            return builder(context, detailRequest);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionProvider.overrideWith((ref) async => const <OwnedItem>[]),
          wishlistProvider.overrideWith((ref) async => const <WishlistItem>[]),
          watchSessionsByItemProvider.overrideWith(
            (ref) => const <String, List<WatchSession>>{},
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.tap(find.byType(LibraryWorkspaceCard));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(LibraryWorkspaceCard));
    await pumpUntilSettled(tester);

    expect(
      find.textContaining(
        'Core has not returned any release records for this title yet.',
      ),
      findsOneWidget,
    );
  });
}
