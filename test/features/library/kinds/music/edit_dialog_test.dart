import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
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

    final type = musicKindModule;
    final item = testCatalogItemWithKindMetadata(
      testCatalogItem(
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

  testWidgets(
      'music edit dialog handles Vinyl format and custom fields cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final type = musicKindModule;
    final item = testCatalogItemWithKindMetadata(
      testCatalogItem(
        id: 'music-vinyl',
        kind: 'music',
        title: 'Dark Side of the Moon',
        physicalFormat: 'Vinyl',
      ),
    );
    final request = LibraryEditDialogRequest(
      type: type,
      item: item,
      ownedItem: null,
      accent: Colors.deepPurple,
      physicalFormats: musicPhysicalMediaFormats,
      customFieldDefinitions: [
        CustomFieldDefinition(
          id: 'custom-1',
          name: 'Pressing',
          fieldType: 'text',
          createdAt: DateTime(2026),
        ),
      ],
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

    expect(tester.takeException(), isNull);
    expect(find.text('Vinyl'), findsWidgets);
  });
}
