import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/metadata/library_link_items_page.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../support/fakes/music_catalog_api_fake.dart';

void main() {
  for (final width in [1200.0, 390.0]) {
    testWidgets(
        'link table at $width searches without linking and manual cancel preserves entry',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const entryRef = LibraryEntryRef(
          kind: CatalogMediaKind.music, id: LibraryEntryId('local'));
      final source = LibraryWorkspaceContext(
          item: WorkspaceItem(
              target: const EntryTargetRef(entryRef),
              entrySummary: const LibraryEntrySummary(ref: entryRef),
              kindPresentationData: MusicWorkspaceData(
                  music: MusicAlbum(
                      title: 'After the Rain', artist: 'The Paper Moons'))),
          personal: PersonalOverlay());
      var writes = 0;
      final api = MusicCatalogApiFake(title: 'After the Rain');
      await tester.pumpWidget(ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(api),
            libraryEntryMutationsProvider.overrideWith((_) {
              writes++;
              throw StateError('Search must not write');
            }),
          ],
          child: MaterialApp(
              theme: buildLibraryTheme(),
              home: LibraryLinkItemsPage(
                  type: defaultLibraryKindRegistry
                      .require(CatalogMediaKind.music),
                  entries: [source]))));
      await tester.pumpAndSettle();
      expect(find.text('Your Album'), findsOneWidget);
      expect(find.text('The Paper Moons'), findsOneWidget);
      await tester.tap(find.text('Find matches'));
      await tester.pumpAndSettle();
      expect(api.lastSearchQuery?.query, 'After the Rain');
      expect(writes, 0);
      expect(find.text('Accept'), findsOneWidget);
      final bulk = tester.widget<FilledButton>(find.widgetWithText(
          FilledButton, 'Link 0 albums with high match-score'));
      expect(bulk.onPressed, isNull);
      // Bring the table row into view on compact screens.
      await tester.ensureVisible(find.text('Link manually'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Link manually'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Accept'), findsOneWidget);
      expect(writes, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a fully linked collection says so in the kind words',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            theme: buildLibraryTheme(),
            home: LibraryLinkItemsPage(
                type:
                    defaultLibraryKindRegistry.require(CatalogMediaKind.comic),
                entries: const []))));
    await tester.pumpAndSettle();
    // As the reference Link Comics page reads.
    expect(find.text('Your Comic'), findsOneWidget);
    expect(find.text('Core comics'), findsOneWidget);
    expect(find.text('All comics are linked.'), findsOneWidget);
  });
}
