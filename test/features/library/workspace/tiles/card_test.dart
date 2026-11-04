import 'package:collectarr_app/features/library/workspace/tiles/card_footer.dart';
import 'dart:ui' as ui;
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/workspace.dart';
import 'package:collectarr_app/features/library/generic/page/controllers/selection_controller.dart';
import 'package:collectarr_app/features/library/generic/page/session.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:collectarr_app/features/library/workspace/entry/context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/features/library/workspace/table/row.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_icon.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/slab.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _selected = Color(0xff2a7fd4);
const _probe = Key('probe');

LibraryProjectionItem _item({String? collectionStatus}) {
  final entry = MusicLibraryEntry(
    id: const LibraryEntryId('a'),
    sourceCatalogRef:
        const CatalogItemRef(kind: CatalogMediaKind.music, id: 'catalog-a'),
    updatedAt: DateTime.utc(2026, 10, 10),
    personal:
        MusicPersonalData(indexNumber: 1, collectionStatus: collectionStatus),
    metadata: MusicAlbum(title: 'Album'),
  );
  final summary = MusicLibraryEntryProjection.toSummary(entry);
  return LibraryProjectionItem.fromShelf(
    LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: EntryTargetRef(summary.ref),
        entrySummary: summary,
        libraryEntryDispatch: OpaqueLibraryEntryDispatch(
            ref: summary.ref, kind: CatalogMediaKind.music, value: entry),
        kindPresentationData: MusicWorkspaceData.fromMusic(entry.metadata),
      ),
      personal: const PersonalOverlay(),
    ),
    const MusicRegistration(),
  );
}

/// Hovers [target], clicks it (which selects it) and returns the colour of
/// the pixel at [probe], relative to the target's top left, with the mouse
/// still over it.
Future<Color> _colorAfterClick(
    WidgetTester tester, Finder target, Offset probe) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(target));
  await tester.pumpAndSettle();
  await mouse.down(tester.getCenter(target));
  await tester.pump();
  await mouse.up();
  await tester.pumpAndSettle();
  // Let the double-tap window close so no gesture timer is left pending.
  await tester.pump(kDoubleTapTimeout);

  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_probe));
  final origin = boundary.localToGlobal(Offset.zero);
  final at = tester.getTopLeft(target) + probe - origin;
  final pixels = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  }))!;
  final offset =
      (at.dy.round() * boundary.size.width.round() + at.dx.round()) * 4;
  return Color.fromARGB(
    pixels.getUint8(offset + 3),
    pixels.getUint8(offset),
    pixels.getUint8(offset + 1),
    pixels.getUint8(offset + 2),
  );
}

Widget _host(
  LocalDatabase db,
  Widget Function(bool selected, VoidCallback select) builder,
) {
  var selected = false;
  return ProviderScope(
    overrides: [localDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => Center(
            child: RepaintBoundary(
              key: _probe,
              child: builder(selected, () => setState(() => selected = true)),
            ),
          ),
        ),
      ),
    ),
  );
}

LibraryProjectionItem _comicItem({bool isSlabbed = false}) {
  final entry = ComicLibraryEntry(
    id: const LibraryEntryId('comic-1'),
    updatedAt: DateTime.utc(2026, 10, 10),
    personal: ComicPersonalData(
      details: ComicEntryDetails(
        rawOrSlabbed: isSlabbed ? 'Slabbed' : 'Raw',
        gradingCompany: 'CGC',
      ),
      grade: '9.8',
    ),
    metadata: const ComicCatalogItem(
      title: 'Issue 1',
      seriesTitle: 'Batman',
      issueNumber: '1',
    ),
  );
  final summary = ComicLibraryEntryProjection.toSummary(entry);
  return LibraryProjectionItem.fromShelf(
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
    const ComicRegistration(),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final mode in [
    LibraryViewMode.grid,
    LibraryViewMode.card,
    LibraryViewMode.horizontalCards,
    LibraryViewMode.shelves,
    LibraryViewMode.list
  ]) {
    testWidgets(
        'mobile $mode opens normally and selects only in selection mode',
        (tester) async {
      final item = _item();
      final selection = LibraryPageSelectionSession();
      var opened = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          localItemImageProvider
              .overrideWith((ref, request) => Stream.value(null))
        ],
        child: MaterialApp(
            home: Scaffold(body: StatefulBuilder(builder: (context, setState) {
          final controller = LibraryPageSelectionController(
            selection: selection,
            facets: LibraryPageFacetSession(),
            isMounted: () => true,
            mutateState: (fn) => setState(fn),
            hasItemDrilldown: () => false,
            drilldownRootItemId: () => null,
            closeItemDrilldown: () {},
            hydrateSelectedItem: (_) async {},
            removeVisibleSelection: (_) {},
          );
          return Column(children: [
            TextButton(
                onPressed: () => setState(() => selection.value =
                    selection.value.setEnabled(!selection.value.enabled)),
                child: const Text('Selection mode')),
            Expanded(
                child: LibraryWorkspace(
              type: const MusicRegistration(),
              items: [item],
              viewState: libraryViewProfileForKind(CatalogMediaKind.music)
                  .defaults()
                  .copyWith(viewMode: mode),
              selectedId: item.target.id,
              selectedAnchorId: null,
              selectionEnabled: selection.value.enabled,
              selectedIds: selection.value.itemIds,
              groupMode: '',
              groupPresentation: LibraryGroupPresentation.inlineHeaders,
              selectedBucket: null,
              onBucketChanged: (_) {},
              collapsedGroupBuckets: const {},
              onGroupBucketCollapsedToggled: (_) {},
              accent: Colors.blue,
              hasActiveFilter: false,
              onClearFilters: () {},
              onApplySelection: (_, __) {},
              onActivateItem: (_) {},
              onToggleSelectionItem: controller.toggleSelectionItem,
              onOpenItem: (_) => opened++,
              onEditItem: (_) {},
              onSortChanged: (_) {},
              onColumnWidthChanged: (_, __) {},
            )),
          ]);
        }))),
      ));
      await tester.pumpAndSettle();
      final target =
          mode == LibraryViewMode.grid || mode == LibraryViewMode.shelves
              ? find.byType(LibraryCoverTile)
              : mode == LibraryViewMode.list
                  ? find.text('Album')
                  : find.byType(LibraryWorkspaceCard);
      if (mode == LibraryViewMode.grid || mode == LibraryViewMode.shelves) {
        expect(tester.widget<LibraryCoverTile>(target).active, isFalse);
      } else if (mode != LibraryViewMode.list) {
        expect(tester.widget<LibraryWorkspaceCard>(target).selected, isFalse);
      }
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(opened, 1);
      expect(selection.value.enabled, isFalse);
      await tester.longPress(target);
      await tester.pumpAndSettle();
      expect(selection.value.enabled, isFalse);
      final openedBeforeSelection = opened;
      await tester.tap(find.text('Selection mode'));
      await tester.pumpAndSettle();
      final bounds = tester.getRect(target);
      await tester.tapAt(mode == LibraryViewMode.list
          ? bounds.center
          : bounds.topRight + const Offset(-8, 8));
      await tester.pumpAndSettle();
      expect(selection.value.itemIds, {item.target.id});
      expect(opened, openedBeforeSelection);
      await tester.tapAt(mode == LibraryViewMode.list
          ? bounds.center
          : bounds.bottomRight + const Offset(-8, -8));
      await tester.pumpAndSettle();
      expect(selection.value.itemIds, isEmpty);
      expect(selection.value.enabled, isTrue);
      expect(opened, openedBeforeSelection);
      if (mode != LibraryViewMode.list) {
        final unchecked = tester.widget<LibraryTileSelectionToggle>(
            find.byType(LibraryTileSelectionToggle));
        expect(unchecked.selected, isFalse);
        await tester.tap(find.byType(LibraryTileSelectionToggleButton));
        await tester.pumpAndSettle();
        expect(selection.value.itemIds, {item.target.id});
        final checked = tester.widget<LibraryTileSelectionToggle>(
            find.byType(LibraryTileSelectionToggle));
        expect(checked.selected, isTrue);
        expect(opened, openedBeforeSelection);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: bounds.center);
        await mouse.down(bounds.center);
        await mouse.moveBy(const Offset(1, 1));
        await mouse.up();
        await tester.pumpAndSettle();
        expect(selection.value.itemIds, isEmpty);
        expect(selection.value.enabled, isTrue);
        expect(opened, openedBeforeSelection);
        await mouse.removePointer();
      }
    }, variant: TargetPlatformVariant({TargetPlatform.android}));
  }

  testWidgets('headlined cards put the headline above the cover',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localItemImageProvider
            .overrideWith((ref, request) => Stream.value(null))
      ],
      child: MaterialApp(
        theme: buildAppShellTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
            body: SizedBox(
          width: 158,
          height: 320,
          child: LibraryWorkspaceCard(
              item: _item(),
              selected: false,
              onTap: () {},
              cardLayout: LibraryCardLayout.headlined),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    final headline = find.text('Album');
    expect(headline, findsOneWidget);
    expect(tester.widget<Text>(headline).textAlign, TextAlign.center);
    expect(tester.getTopLeft(headline).dy, lessThan(10));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('raw headlined cards keep the top title with 5 px side padding',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localItemImageProvider
            .overrideWith((ref, request) => Stream.value(null))
      ],
      child: MaterialApp(
        theme: buildAppShellTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
            body: SizedBox(
          width: 158,
          height: 320,
          child: LibraryWorkspaceCard(
              item: _comicItem(isSlabbed: false),
              selected: false,
              onTap: () {},
              cardLayout: LibraryCardLayout.headlined),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    final headline = find.text('Batman');
    expect(headline, findsOneWidget);
    final padding = tester.widget<Padding>(
        find.ancestor(of: headline, matching: find.byType(Padding)).first);
    expect(padding.padding, const EdgeInsets.fromLTRB(5, 3, 5, 0));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('slabbed headlined cards keep the top title and render the slab',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localItemImageProvider
            .overrideWith((ref, request) => Stream.value(null))
      ],
      child: MaterialApp(
        theme: buildAppShellTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
            body: SizedBox(
          width: 158,
          height: 320,
          child: LibraryWorkspaceCard(
              item: _comicItem(isSlabbed: true),
              selected: false,
              onTap: () {},
              cardLayout: LibraryCardLayout.headlined),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Batman'), findsOneWidget);
    expect(find.byType(ComicSlab), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('vertical cards align cover to top and omit top headline',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localItemImageProvider
            .overrideWith((ref, request) => Stream.value(null))
      ],
      child: MaterialApp(
        theme: buildAppShellTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
            body: SizedBox(
          width: 158,
          height: 280,
          child: LibraryWorkspaceCard(
              item: _item(),
              selected: false,
              onTap: () {},
              cardLayout: LibraryCardLayout.vertical),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Album'), findsOneWidget);
    final titlePos = tester.getTopLeft(find.text('Album'));
    expect(titlePos.dy, greaterThan(200));
    final interactiveCover = tester
        .widget<LibraryInteractiveCover>(find.byType(LibraryInteractiveCover));
    expect(interactiveCover.alignment, Alignment.topCenter);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('headlined cards drop the headline inside its folder',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localItemImageProvider
            .overrideWith((ref, request) => Stream.value(null))
      ],
      child: MaterialApp(
        theme: buildAppShellTheme(palette: kDefaultAppThemePalette),
        home: Scaffold(
            body: SizedBox(
          width: 158,
          height: 280,
          child: LibraryWorkspaceCard(
              item: _item(),
              selected: false,
              onTap: () {},
              cardLayout: LibraryCardLayout.headlined,
              showHeadline: false),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Album'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('light vertical cards keep readable titles before selection',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localItemImageProvider
            .overrideWith((ref, request) => Stream.value(null))
      ],
      child: MaterialApp(
        theme: buildAppShellTheme(palette: kLightAppThemePalette),
        home: Scaffold(
            body: SizedBox(
          width: 180,
          height: 300,
          child: LibraryWorkspaceCard(
              item: _item(),
              selected: false,
              onTap: () {},
              cardLayout: LibraryCardLayout.vertical),
        )),
      ),
    ));
    await tester.pumpAndSettle();
    final title = tester.widget<Text>(find.text('Album'));
    final ink = title.style!.color!.computeLuminance();
    final paper = kLightAppThemePalette.panelRaised.computeLuminance();
    expect((paper + 0.05) / (ink + 0.05), greaterThanOrEqualTo(4.5));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  for (final width in [160.0, 240.0]) {
    testWidgets('card footer reserves value and status space at $width px',
        (tester) async {
      const platform = 'A very long platform name that needs truncation';
      const value = 'CIB | USD 12345.67';
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  width: width,
                  height: 24,
                  child: const LibraryCardFooter(
                      label: platform,
                      value: value,
                      selected: false,
                      status: SizedBox(
                          key: ValueKey('status'), width: 21, height: 21))))));
      final labelBox = tester.getRect(find.text(platform));
      final valueBox = tester.getRect(find.text(value));
      final statusBox = tester.getRect(find.byKey(const ValueKey('status')));
      expect(labelBox.right, lessThanOrEqualTo(valueBox.left));
      expect(valueBox.right, lessThanOrEqualTo(statusBox.left));
      expect(tester.widget<Text>(find.text(platform)).overflow,
          TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'a horizontal card shorter than its text clips instead of overflowing',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = _item();
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 60,
              child: LibraryWorkspaceCard(
                item: item,
                customFieldBadges: const ['Signed', 'First press'],
                selected: selected,
                selectedColor: _selected,
                onTap: select,
              ),
            )));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a card clicked under the mouse shows its selection colour',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = _item();
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 88,
              child: LibraryWorkspaceCard(
                item: item,
                selected: selected,
                selectedColor: _selected,
                onTap: select,
              ),
            )));
    await tester.pumpAndSettle();

    final color = await _colorAfterClick(
        tester, find.byType(LibraryWorkspaceCard), const Offset(250, 70));

    expect(color, _selected);
    // Unmount before the database closes so its query timers finish.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a list row clicked under the mouse shows its selection colour',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 30,
              child: LibraryTableInkRow(
                density: LibraryDensity.comfortable,
                selected: selected,
                odd: false,
                onTap: select,
                selectedColor: _selected,
                oddColor: Colors.grey,
                evenColor: Colors.grey,
                selectionRailColor: _selected,
                bottomBorderColor: Colors.grey,
                hoverColor: const Color(0xff464950),
                child: const SizedBox(height: 28),
              ),
            )));
    await tester.pumpAndSettle();

    final color = await _colorAfterClick(
        tester, find.byType(LibraryTableInkRow), const Offset(200, 14));

    expect(color, _selected);
  });

  testWidgets('a card shows the collection status of its entry',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = _item(collectionStatus: 'For Sale');
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 88,
              child: LibraryWorkspaceCard(
                  item: item, selected: false, onTap: select),
            )));
    await tester.pumpAndSettle();

    expect(
        tester
            .widget<LibraryCollectionStatusMark>(
                find.byType(LibraryCollectionStatusMark))
            .collectionStatus,
        LibraryCollectionStatusScope.forSale);
    expect(find.byTooltip('For Sale'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
