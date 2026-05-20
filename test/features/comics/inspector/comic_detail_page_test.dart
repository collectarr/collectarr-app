import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/inspector/comic_detail_page.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('comic detail page renders rich metadata and local status',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          comicDetailProvider('comic-1').overrideWith(
            (ref) async => _detail(),
          ),
          shelfProvider.overrideWith((ref) async => _shelf()),
        ],
        child: const MaterialApp(
          home: ComicDetailPage(item: _catalogItem),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Batman'), findsWidgets);
    expect(find.text('Local status'), findsOneWidget);
    expect(find.text('Short Box 1'), findsOneWidget);
    expect(find.text('Primary variant'), findsOneWidget);
    expect(find.text('Cover A'), findsWidgets);
    expect(find.text('Provider links'), findsOneWidget);
    expect(find.text('Creators'), findsWidgets);
  });
}

const _catalogItem = CatalogItem(
  id: 'comic-1',
  kind: 'comic',
  title: 'Batman',
  itemNumber: '1',
  publisher: 'DC',
);

ComicDetail _detail() {
  return ComicDetail(
    id: 'comic-1',
    kind: 'comic',
    title: 'Batman',
    itemNumber: '1',
    publisher: 'DC',
    barcode: '76194134192700111',
    pageCount: 32,
    coverPriceCents: 399,
    currency: 'USD',
    creators: const [ComicCredit(name: 'Writer One', role: 'Writer')],
    characters: const [ComicCredit(name: 'Bruce Wayne')],
    providerLinks: const [
      ComicProviderLink(
        provider: 'gcd',
        entityType: 'issue',
        providerItemId: '123',
        siteUrl: 'https://example.test/gcd/123',
      ),
    ],
    editions: [
      ComicEdition(
        id: 'edition-1',
        title: 'Batman #1',
        format: 'Single Issue',
        publisher: 'DC',
        releaseDate: DateTime.utc(2024, 1, 10),
        variants: const [
          ComicVariant(
            id: 'variant-1',
            name: 'Cover A',
            isPrimary: true,
            variantType: 'Regular',
            barcode: '76194134192700111',
            coverPriceCents: 399,
            currency: 'USD',
          ),
        ],
        releases: [
          ComicRelease(
            id: 'release-1',
            region: 'US',
            publisher: 'DC',
            releaseDate: DateTime.utc(2024, 1, 10),
          ),
        ],
      ),
    ],
  );
}

ShelfState _shelf() {
  return ShelfState(
    entries: [
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: _catalogItem,
        ownedItem: OwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          condition: 'Near Mint',
          grade: '9.8',
          quantity: 1,
          storageBox: 'Short Box 1',
          updatedAt: DateTime.utc(2026, 5, 14),
        ),
      ),
    ],
    ownedCount: 1,
    wishlistCount: 0,
    missingGradeCount: 0,
    pricedCount: 0,
    totalPaidCents: null,
    primaryCurrency: null,
    hasMixedCurrencies: false,
  );
}
