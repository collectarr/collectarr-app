import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/detail/location.dart';
import 'package:collectarr_app/features/library/detail/page.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../support/app/provider_overrides.dart';
import '../../../support/app/test_app_harness.dart';
import '../../../support/fixtures/music_fixtures.dart';
import '../../../support/fixtures/test_constants.dart';

void main() {
  test('stable locations distinguish catalog and entry namespaces', () {
    for (final target in <LibraryTargetRef>[
      const CatalogTargetRef(
          CatalogItemRef(kind: CatalogMediaKind.music, id: 'same/id ?')),
      const EntryTargetRef(LibraryEntryRef(
          kind: CatalogMediaKind.music, id: LibraryEntryId('same/id ?'))),
    ]) {
      final uri = LibraryDetailLocation(target).toUri();
      expect(LibraryDetailLocation.fromUri(uri)?.target, target);
      expect(uri.queryParameters.length, 3);
    }
    for (final query in [
      'kind=unknown&target=entry&id=x',
      'kind=music&target=entry',
      'kind=music&target=other&id=x'
    ]) {
      expect(
          LibraryDetailLocation.fromUri(Uri.parse('/detail?$query')), isNull);
    }
  });

  for (final width in [390.0, 1024.0]) {
    testWidgets(
        'cold local detail, unavailable target and safe Back at $width dp',
        (tester) async {
      setUpTestAppPreferences();
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(() => tester.runAsync(db.close));
      final entry = musicLibraryEntryFixture(
          metadata: musicAlbumFixture(title: 'Offline local album'));
      await tester.runAsync(() => MusicEntryRepository(db).upsert(entry));
      await tester
          .pumpWidget(testApp(overrides: testAppOverrides(database: db)));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      final uri = LibraryDetailLocation(EntryTargetRef(
              LibraryEntryRef(kind: CatalogMediaKind.music, id: entry.id)))
          .toUri();
      router.go(uri.toString());
      await pumpUntilSettled(tester);
      expect(find.byType(LibraryDetailPage), findsOneWidget);
      expect(find.text('Offline local album'), findsWidgets);
      expect(find.byKey(const Key('app.mobile-navigation')), findsNothing);
      expect(tester.takeException(), isNull);
      router.go('/detail?kind=music&target=entry&id=removed');
      await pumpUntilSettled(tester);
      expect(find.text('This item was removed or is not available offline.'),
          findsOneWidget);
      await tester.tap(find.byType(BackButton).first);
      await pumpUntilSettled(tester);
      expect(
          router.routeInformationProvider.value.uri.path, AppRoutes.libraries);
      expect(router.routeInformationProvider.value.uri.queryParameters['kind'],
          'music');
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    },
        variant: TargetPlatformVariant(
            {TargetPlatform.android, TargetPlatform.iOS}));
  }
}
