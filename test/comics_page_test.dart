import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/comics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const catalogItems = [
    CatalogItem(
      id: 'comic-1',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '8A',
      synopsis: 'Escape From Dinosaur Island, Part One',
    ),
    CatalogItem(
      id: 'comic-2',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '9',
      synopsis: 'A follow-up issue.',
    ),
  ];

  testWidgets('comics page shows desktop catalog workspace', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          comicsSearchProvider.overrideWith((ref, query) async {
            return catalogItems;
          }),
          collectionProvider.overrideWith((ref) async {
            return [
              OwnedItem(
                id: 'owned-1',
                itemId: 'comic-1',
                condition: 'Near Mint',
                grade: '9.8',
                updatedAt: DateTime.utc(2026, 5, 11),
              ),
            ];
          }),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: ComicsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Superman, Vol. 4'), findsWidgets);
    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
    expect(find.text('Owned'), findsWidgets);
    expect(find.text('Near Mint'), findsOneWidget);
    expect(find.text('9.8'), findsWidgets);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Move to wishlist'), findsOneWidget);
    expect(find.byTooltip('Grid view'), findsOneWidget);
  });

  testWidgets('compact comics page keeps scan and metadata refresh actions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          comicsSearchProvider.overrideWith((ref, query) async {
            return catalogItems;
          }),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: ComicsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(find.text('Superman, Vol. 4'), findsNothing);
    expect(find.text('Superman, Vol. 4 #8A'), findsWidgets);
  });
}
