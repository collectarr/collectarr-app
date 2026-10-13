import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
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
  });
}

LibraryEditDialogRequest _musicEditRequest() {
  return LibraryEditDialogRequest(
    type: const MusicRegistration(),
    item: CatalogSearchCandidate.fromItem(testCatalogItem(
      id: 'music-1',
      kind: 'music',
      title: 'The Return of the King',
    )),
    libraryEntry: null,
    accent: Colors.orange,
  );
}
