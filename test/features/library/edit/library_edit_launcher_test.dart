import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('showLibraryEditDialog opens immediately while request loads', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final completer = Completer<LibraryEditDialogRequest>();
    final request = _bookEditRequest();

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
    expect(find.text('Opening editor for The Return of the King...'), findsOneWidget);

    completer.complete(request);
    await pumpUntilSettled(tester);

    expect(find.text('Edit book — The Return of the King'), findsOneWidget);
  });
}

LibraryEditDialogRequest _bookEditRequest() {
  return LibraryEditDialogRequest(
    type: booksLibraryConfig,
    item: LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Return of the King',
      ),
    ),
    ownedItem: null,
    accent: Colors.orange,
  );
}