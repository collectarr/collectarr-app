import 'package:collectarr_app/features/library/edit/draft/models.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/edit/launcher.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import '../../../support/builders/catalog_item_builder.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures/test_constants.dart';

void main() {
  for (final width in [390.0, 1024.0]) {
    testWidgets('edit route follows native policy at $width dp',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final loaded = Completer<LibraryEditDialogRequest>();
      var loads = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
          appBar: AppBar(title: const Text('Outer shell')),
          body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (context) => FilledButton(
                      onPressed: () => unawaited(showLibraryEditDialog(
                          context: context,
                          request: _musicEditRequest(),
                          requestLoader: () {
                            loads++;
                            return loaded.future;
                          })),
                      child: const Text('Open editor')))),
        )),
      ));
      await tester.tap(find.text('Open editor'));
      await pumpUntilSettled(tester);
      final route = ModalRoute.of(
          tester.element(find.byType(CircularProgressIndicator)))!;
      if (appPresentationPlatform.isNativeMobile) {
        expect(route, isA<MaterialPageRoute<LibraryEditSelection>>());
        expect((route as PageRoute).fullscreenDialog, isTrue);
        expect(find.text('Outer shell'), findsNothing);
      } else {
        expect(route, isA<AppDialogRoute<LibraryEditSelection>>());
        expect(find.text('Outer shell'), findsOneWidget);
      }
      expect(loads, 1);
      route.navigator!.pop();
      await pumpUntilSettled(tester);
      loaded.complete(_musicEditRequest());
      await pumpUntilSettled(tester);
      expect(find.text('Outer shell'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
        variant: TargetPlatformVariant({
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.windows
        }));
  }

  testWidgets('showLibraryEditDialog opens immediately while request loads', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final completer = Completer<LibraryEditDialogRequest>();
    final request = _musicEditRequest();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () {
                  unawaited(
                    showLibraryEditDialog(
                      context: context,
                      request: request,
                      requestLoader: () => completer.future,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading edit data for The Return of the King...'),
        findsOneWidget);

    completer.complete(request);
    await pumpUntilSettled(tester);

    expect(find.textContaining('The Return of the King'), findsWidgets);
    expect(find.text('Save'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('switching items keeps the dialog on screen with no spinner', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final first = _musicEditRequest();
    final second = _musicEditRequest(title: 'Another Album');
    final listenable = ValueNotifier(first);
    addTearDown(listenable.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => unawaited(showLibraryEditDialog(
                  context: context,
                  request: first,
                  requestListenable: listenable,
                )),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await pumpUntilSettled(tester);
    expect(find.text('Save'), findsOneWidget);

    listenable.value = second;
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Save'), findsOneWidget);
    await pumpUntilSettled(tester);
    expect(find.textContaining('Another Album'), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}

LibraryEditDialogRequest _musicEditRequest({
  String title = 'The Return of the King',
}) {
  return LibraryEditDialogRequest(
    type: const MusicRegistration(),
    item: CatalogSearchCandidate.fromItem(testCatalogItem(
      id: 'music-1',
      kind: 'music',
      title: title,
    )),
    libraryEntry: null,
    accent: Colors.orange,
  );
}
