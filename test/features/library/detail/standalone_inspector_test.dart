import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/dev/seeds/music_inspector_reference_seed.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/generic/page/generic_library_page.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'workspace opens the shared standalone inspector only with No Details',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));
    final fixture = jsonDecode(
        File('tool/fixtures/music_inspector_reference.json')
            .readAsStringSync()) as Map<String, dynamic>;
    final catalog = fixture['catalog'] as Map;
    for (final key in [
      'cover_image_url',
      'thumbnail_image_url',
      'back_cover_image_url'
    ]) {
      catalog.remove(key);
    }
    final entry = (await tester
        .runAsync(() => seedMusicInspectorReference(db, fixture)))!;
    final summary = MusicLibraryEntryProjection.toSummary(entry);
    final shelf = ShelfState.from(entrySummaries: [
      summary
    ], wishlistItems: [], libraryEntryDispatchesByRef: {
      summary.ref: OpaqueLibraryEntryDispatch(
          ref: summary.ref, kind: CatalogMediaKind.music, value: entry)
    }, kindPresentationByEntryRef: {
      summary.ref: MusicWorkspaceData.fromMusic(entry.metadata)
    });
    final container = ProviderContainer(overrides: [
      localDatabaseProvider.overrideWithValue(db),
      shelfProvider.overrideWith((ref) async => shelf),
      mediaCatalogProvider.overrideWith((ref) async => fallbackMediaCatalog),
    ]);
    await container.read(shelfProvider.future);
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, route) => GenericLibraryPage(
              type: const MusicRegistration(),
              topBar: const SizedBox.shrink(),
              accent: Colors.orange,
              routeUri: route.uri)),
      GoRoute(
          path: AppRoutes.detail,
          builder: (_, route) {
            final request = route.extra! as LibraryDetailPageRequest;
            return Scaffold(
                body: LibraryDetailPage(
                    type: request.type,
                    item: request.item,
                    projection: request.projection,
                    libraryEntrySummary: request.libraryEntrySummary,
                    libraryEntryDispatch: request.libraryEntryDispatch,
                    accent: request.accent,
                    onAddEntry: request.onAddEntry,
                    onRemoveEntry: request.onRemoveEntry,
                    onAddWishlist: request.onAddWishlist,
                    onRemoveWishlist: request.onRemoveWishlist,
                    onEdit: request.onEdit));
          }),
    ]);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      container.dispose();
    });
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
    final initialBody = tester.widget<LibraryBody>(find.byType(LibraryBody));
    initialBody
        .onActivateItem(initialBody.projection.filteredItems.single.target.id);
    await tester.pumpAndSettle();
    for (final layout in [
      LibraryDetailsLayout.right,
      LibraryDetailsLayout.bottom
    ]) {
      tester
          .widget<LibraryDetailsLayoutDropdown>(
              find.byType(LibraryDetailsLayoutDropdown).first)
          .onChanged(layout);
      await tester.pumpAndSettle();
      final body = tester.widget<LibraryBody>(find.byType(LibraryBody));
      expect(body.viewState.detailsLayout, layout);
      body.onOpenItem(body.projection.filteredItems.single);
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
      expect(find.byType(LibraryDetailPage), findsNothing);
      expect(find.byType(LibraryInspector), findsOneWidget);
    }
    tester
        .widget<LibraryDetailsLayoutDropdown>(
            find.byType(LibraryDetailsLayoutDropdown).first)
        .onChanged(LibraryDetailsLayout.hidden);
    await tester.pumpAndSettle();
    final body = tester.widget<LibraryBody>(find.byType(LibraryBody));
    expect(body.viewState.detailsLayout, LibraryDetailsLayout.hidden);
    body.onOpenItem(body.projection.filteredItems.single);
    await tester.pumpAndSettle();
    expect(
        router.routerDelegate.currentConfiguration.matches.last.matchedLocation,
        AppRoutes.detail);
    expect(
        tester
            .widget<LibraryInspector>(find.byType(LibraryInspector))
            .fullscreen,
        isTrue);
    expect(find.byType(InspectorUnifiedToolbar), findsOneWidget);
    expect(find.text(entry.metadata.title), findsWidgets);

    final trigger = find.byTooltip('More inspector actions');
    final anchor = tester.getRect(trigger);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    final duplicate = find.ancestor(
        of: find.text('Duplicate'), matching: find.byType(MenuItemButton));
    expect(
        tester.getRect(duplicate).left, greaterThanOrEqualTo(anchor.left - 6));
    expect(find.text('Move to other collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
