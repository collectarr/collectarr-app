import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music links tab exposes editable external links',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final type = collectarrLibraryTypes.byKind('music')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Test Album',
      ),
    );
    final request = LibraryEditDialogRequest(
      type: type,
      item: item,
      ownedItem: null,
      accent: Colors.deepPurple,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (context) =>
                        buildMusicLibraryEditDialog(context, request),
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
    await tester.pumpAndSettle();

    final linksTab = find.text('Links').last;
    await tester.ensureVisible(linksTab);
    await tester.tap(linksTab);
    await tester.pumpAndSettle();

    expect(find.text('Add link'), findsOneWidget);
    await tester.tap(find.text('Add link'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('musicExternalLinkUrlField_0')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('musicExternalLinkDescriptionField_0')),
        findsOneWidget);
  });
}
