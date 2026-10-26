import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_shelf_view.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
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
