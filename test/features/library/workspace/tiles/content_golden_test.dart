import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';

import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/workspace/layout/flow_carousel.dart';
import 'package:collectarr_app/features/library/workspace/layout/shelf_view.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/data.dart';

LibraryProjectionItem _item({String? collectionStatus}) {
  final entry = MusicLibraryEntry(
    id: const LibraryEntryId('a'),
    sourceCatalogRef:
        const CatalogItemRef(kind: CatalogMediaKind.music, id: 'catalog-a'),
    updatedAt: DateTime.utc(2026, 10, 10),
    personal:
        MusicPersonalData(indexNumber: 1, collectionStatus: collectionStatus),
    metadata: MusicAlbum(
        title: 'A very long album title for the presentation contract',
        artist: 'Artist',
        publisher: 'Publisher',
        releaseDateParts: const PartialDate(year: 2025, month: 3, day: 2)),
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
      variant: 'A',
      releaseDateParts: PartialDate(year: 2025, month: 1, day: 2),
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

LibraryProjectionItem _gameItem() {
  final entry = GameLibraryEntry(
      id: const LibraryEntryId('game-1'),
      updatedAt: DateTime.utc(2026),
      personal: const GamePersonalData(marketValueCents: 1500, currency: 'USD'),
      metadata: const GameCatalogMetadata(
          title: 'A very long game title for the presentation contract',
          platforms: ['Nintendo Switch'],
          releaseDateParts: PartialDate(year: 2025, month: 2, day: 3)));
  final summary = GameLibraryEntryProjection.toSummary(entry);
  return LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
          item: WorkspaceItem(
              target: EntryTargetRef(summary.ref),
              entrySummary: summary,
              libraryEntryDispatch: OpaqueLibraryEntryDispatch(
                  ref: summary.ref, kind: CatalogMediaKind.game, value: entry),
              kindPresentationData:
                  GameWorkspaceData(metadata: entry.metadata)),
          personal: const PersonalOverlay()),
      const GameRegistration());
}

List<LibraryProjectionItem> _states(LibraryProjectionItem owned) {
  final kind = owned.source.mediaKind;
  LibraryProjectionItem catalog(String id, {bool wishlist = false}) {
    final ref = CatalogItemRef(kind: kind, id: id);
    return LibraryProjectionItem.fromShelf(
        LibraryWorkspaceContext(
            item: WorkspaceItem(
                target: CatalogTargetRef(ref),
                presentation: CatalogDisplaySummary(
                    ref: ref, kind: kind, primaryLabel: owned.dto.primaryLabel),
                kindPresentationData: owned.source.kindPresentationData),
            personal: PersonalOverlay(
                wishlist: wishlist
                    ? WishlistItem(
                        id: 'wish-$id',
                        catalogRef: ref,
                        createdAt: DateTime.utc(2026),
                        updatedAt: DateTime.utc(2026))
                    : null)),
        collectarrKindRegistrations[kind]!);
  }

  return [owned, catalog('catalog'), catalog('wishlist', wishlist: true)];
}

Widget _view(String view, List<LibraryProjectionItem> items) => switch (view) {
      'flow' => LibraryFlowCarousel(
          items: items,
          selectedId: items.first.target.id,
          accent: Colors.blue,
          emptyBuilder: (_) => const SizedBox(),
          onActivateItem: (_) {},
          onOpenItem: (_) {}),
      'shelf' => LibraryShelfView<LibraryProjectionItem>(
          items: items,
          entryOf: (item) => item,
          isActive: (item) => item == items.first,
          isSelected: (item) => item == items[1],
          selectionEnabled: true,
          onTap: (_) {},
          onToggleSelectionItem: (_) {},
          onDoubleTap: (_) {},
          accent: Colors.blue,
          shelfHeight: 240,
          bookWidth: 120),
      'cover' => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
                child: SizedBox(
                    height: 300,
                    child: LibraryCoverTile(
                        item: items[i],
                        active: i == 0,
                        selected: i == 1,
                        selectionMode: true,
                        onTap: () {},
                        onSelectionToggleTap: () {})))
        ]),
      'vertical' => Wrap(spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < items.length; i++)
            SizedBox(
                width: 180,
                height: 320,
                child: LibraryWorkspaceCard(
                    item: items[i],
                    selected: i == 0,
                    selectionMode: true,
                    checked: i == 1,
                    onSelectionToggleTap: () {},
                    onTap: () {},
                    cardLayout: LibraryCardLayout.vertical)),
        ]),
      _ => Column(children: [
          for (var i = 0; i < items.length; i++)
            SizedBox(
                height: 180,
                child: LibraryWorkspaceCard(
                    item: items[i],
                    selected: i == 0,
                    selectionMode: true,
                    checked: i == 1,
                    onSelectionToggleTap: () {},
                    onTap: () {}))
        ]),
    };

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final kind in ['music', 'game', 'comic']) {
    for (final platform in [TargetPlatform.windows, TargetPlatform.android]) {
      for (final view in ['cover', 'vertical', 'horizontal', 'flow', 'shelf']) {
        testWidgets('$kind $view preserves ${platform.name} presentation',
            (tester) async {
          final width = platform == TargetPlatform.windows ? 900.0 : 390.0;
          tester.view.physicalSize = Size(width, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final items = _states(switch (kind) {
            'comic' => _comicItem(isSlabbed: true),
            'game' => _gameItem(),
            _ => _item()
          });
          await tester.pumpWidget(ProviderScope(
              overrides: [
                localItemImageProvider
                    .overrideWith((ref, request) => Stream.value(null))
              ],
              child: MaterialApp(
                  theme: buildAppShellTheme(palette: kDefaultAppThemePalette),
                  home: Scaffold(
                      body: RepaintBoundary(
                          key: const ValueKey('content'),
                          child: SizedBox(
                              width: width,
                              height: 700,
                              child: _view(view, items)))))));
          await tester.pumpAndSettle();
          await expectLater(find.byKey(const ValueKey('content')),
              matchesGoldenFile('goldens/${kind}_${platform.name}_$view.png'));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        }, variant: TargetPlatformVariant.only(platform));
      }
    }
  }
}
