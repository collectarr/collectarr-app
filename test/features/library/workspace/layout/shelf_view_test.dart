import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/layout/shelf_view.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  for (final pixelRatio in [1.0, 2.0]) {
    for (final bookWidth in [120.0, 240.0]) {
      testWidgets(
          'shelf cover keeps detail at $bookWidth px and $pixelRatio DPR',
          (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = const Size(1600, 1000);
        tester.view.devicePixelRatio = pixelRatio;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(ProviderScope(
            child: MaterialApp(
                home: Scaffold(
                    body: LibraryShelfView<LibraryProjectionItem>(
          items: _items(),
          entryOf: (item) => item,
          isActive: (_) => false,
          isSelected: (_) => false,
          selectionEnabled: false,
          onTap: (_) {},
          onToggleSelectionItem: (_) {},
          onDoubleTap: (_) {},
          accent: Colors.blue,
          bookWidth: bookWidth,
          shelfHeight: bookWidth / .7,
        )))));
        await tester.pumpAndSettle();
        final tile = find.byType(LibraryCoverTile).first;
        final cover = tester.widget<LibraryInteractiveCover>(find.descendant(
            of: tile, matching: find.byType(LibraryInteractiveCover)));
        final physicalWidth = tester.getSize(tile).width * pixelRatio;
        expect(cover.targetCacheWidth,
            greaterThanOrEqualTo((physicalWidth * 2).ceil()),
            reason: 'Decode detail before the final downsample, rather than '
                'magnifying a thumbnail-sized texture on desktop.');
      });
    }
  }

  for (final ratio in [0.7, 1.0]) {
    testWidgets('shelf books keep the $ratio cover aspect ratio',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
              home: Scaffold(
                  body: LibraryShelfView<LibraryProjectionItem>(
        items: _items(),
        entryOf: (item) => item,
        isActive: (_) => false,
        isSelected: (_) => false,
        selectionEnabled: false,
        onTap: (_) {},
        onToggleSelectionItem: (_) {},
        onDoubleTap: (_) {},
        accent: Colors.red,
        bookWidth: 120,
        shelfHeight: 120 / ratio,
        fallbackCoverAspectRatio: ratio,
      )))));
      await tester.pumpAndSettle();
      final book = tester.getSize(find.byType(LibraryCoverTile).first);
      expect(book.width / book.height, closeTo(ratio, 0.01));
    });
  }
}

List<LibraryProjectionItem> _items() {
  final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
  final entries = [
    testLibraryWorkspaceSource(
      itemId: 'catalog-a',
      kind: 'music',
      title: 'Album a',
      catalogData: MusicWorkspaceData.fromMusic(MusicAlbum(
        id: CatalogItemRef(kind: CatalogMediaKind.music, id: 'catalog-a'),
        title: 'Album a',
      )),
    ),
  ];
  return libraryItemsForShelf(
      ShelfState(
          entries: entries,
          entryCount: entries.length,
          wishlistCount: 0,
          pricedCount: 0,
          totalPaidCents: null,
          primaryCurrency: null,
          hasMixedCurrencies: false),
      type);
}
