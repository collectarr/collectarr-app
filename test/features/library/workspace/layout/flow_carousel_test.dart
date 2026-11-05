import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/slab.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/layout/flow_carousel.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  testWidgets('flow renders a comic slab supplied by its kind', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final entry = ComicLibraryEntry(
      id: const LibraryEntryId('comic-1'),
      updatedAt: DateTime.utc(2026),
      personal: const ComicPersonalData(
        details:
            ComicEntryDetails(rawOrSlabbed: 'Slabbed', gradingCompany: 'CGC'),
        grade: '9.8 Near Mint/Mint',
      ),
      metadata: const ComicCatalogItem(
          title: 'Issue 1', seriesTitle: 'Batman', issueNumber: '42'),
    );
    final summary = ComicLibraryEntryProjection.toSummary(entry);
    final item = LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
        item: WorkspaceItem(
          target: EntryTargetRef(summary.ref),
          entrySummary: summary,
          libraryEntryDispatch: OpaqueLibraryEntryDispatch(
              ref: summary.ref, kind: CatalogMediaKind.comic, value: entry),
          kindPresentationData: ComicWorkspaceData(comic: entry.metadata),
        ),
        personal: const PersonalOverlay(),
      ),
      libraryKindRegistrationForKind(CatalogMediaKind.comic),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localItemImageProvider
            .overrideWith((ref, request) => Stream.value(null))
      ],
      child: MaterialApp(
          home: Scaffold(
              body: LibraryFlowCarousel(
        items: [item],
        selectedId: null,
        accent: Colors.red,
        emptyBuilder: (_) => const SizedBox.shrink(),
        onActivateItem: (_) {},
        onOpenItem: (_) {},
      ))),
    ));
    await tester.pump();
    expect(find.byType(ComicSlab), findsOneWidget);
    expect(find.text('9.8'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Text &&
          widget.data == '#42' &&
          widget.textAlign == TextAlign.center &&
          widget.maxLines == 1),
      findsOneWidget,
    );
    expect(find.byType(LibraryTileSelectionToggle), findsNothing);
  });

  testWidgets('flow only focuses an item even when control-clicked or hovered',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final activated = <String>[];
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: LibraryFlowCarousel(
            items: _items(),
            selectedId: null,
            accent: Colors.red,
            emptyBuilder: (_) => const SizedBox.shrink(),
            onActivateItem: activated.add,
            onOpenItem: (_) {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final cover = find.byType(LibraryInteractiveCover).first;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(cover));
    await tester.pump();
    expect(find.byType(LibraryTileSelectionToggle), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.tap(find.text('Album a').first);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump(const Duration(milliseconds: 400));
    expect(activated, ['catalog-a']);
    expect(find.byType(LibraryTileSelectionToggle), findsNothing);
    await mouse.removePointer();
    debugDefaultTargetPlatformOverride = null;
  });

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
        accent: Colors.red,
        emptyBuilder: (_) => const SizedBox.shrink(),
        coverAspectRatio: ratio,
        onActivateItem: (_) {},
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
