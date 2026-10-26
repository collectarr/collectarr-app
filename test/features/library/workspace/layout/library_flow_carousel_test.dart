import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_flow_carousel.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  for (final ratio in [0.7, 1.0]) {
    testWidgets('flow covers keep the $ratio aspect ratio without bars',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final items = _items();
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
              home: Scaffold(
                  body: LibraryFlowCarousel(
        items: items,
        selectedId: null,
        selectedAnchorId: null,
        selectedIds: const {},
        accent: Colors.red,
        emptyBuilder: (_) => const SizedBox.shrink(),
        coverAspectRatio: ratio,
        onApplySelection: (_, __) {},
        onActivateItem: (_) {},
        onToggleSelectionItem: (_) {},
        onOpenItem: (_) {},
      )))));
      await tester.pump();
      final cover = tester.getSize(find.byType(LibraryInteractiveCover).first);
      expect(cover.width / cover.height, closeTo(ratio, 0.01));
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
