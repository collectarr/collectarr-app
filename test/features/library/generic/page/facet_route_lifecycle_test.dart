import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/facet_controller_provider.dart';
import 'package:collectarr_app/features/library/generic/page/generic_library_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('route updates load facets after build and retain page state',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));
    final container = ProviderContainer(overrides: [
      localDatabaseProvider.overrideWithValue(db),
      shelfProvider.overrideWith(
          (ref) async => ShelfState.from(wishlistItems: const [])),
    ]);
    await container.read(shelfProvider.future);
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, route) => GenericLibraryPage(
          key: const ValueKey('library-page'),
          type: route.uri.queryParameters['kind'] == 'book'
              ? const BookRegistration()
              : const MusicRegistration(),
          topBar: const SizedBox.shrink(),
          accent: Colors.orange,
          routeUri: route.uri,
        ),
      ),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 3));
    final pageState = tester.state(find.byType(GenericLibraryPage));
    router.go('/?kind=music&folder=group.music.genre&folders=1');
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    expect(tester.state(find.byType(GenericLibraryPage)), same(pageState));
    final facets = container.read(libraryFacetControllerProvider('music'));
    expect(facets.bucketsByFacetId.keys.map((id) => id.value),
        contains('music.genre'));
    expect(facets.loadsInFlight, isEmpty);
    router.go('/?kind=book&folder=group.book.publisher&folders=1');
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    expect(tester.state(find.byType(GenericLibraryPage)), same(pageState));
    expect(
        router.routerDelegate.currentConfiguration.uri.queryParameters['kind'],
        'book');
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    container.dispose();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
