import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../helpers/test_constants.dart';

void main() {
  testWidgets(
      'comic edit dialog saves expanded comic payload and external links',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    final catalog = CatalogCacheRepository(db);
    addTearDown(db.close);

    await catalog.upsertAll([
      CatalogItem(
        id: 'catalog-1',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetails(
          seriesId: 'series-1',
          seriesTitle: 'Saga',
        ),
      ),
      CatalogItem(
        id: 'catalog-2',
        kind: 'comic',
        title: 'OTGW #1',
        series: const CatalogSeriesDetails(
          seriesId: 'series-2',
          seriesTitle: 'Over the Garden Wall',
        ),
      ),
    ]);

    final type = collectarrLibraryTypes.byKind('comic')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Saga',
        titleExtension: 'Chapter Zero',
        itemNumber: '1',
        variant: 'A',
        barcode: '1234567890',
        physicalFormatLabel: 'Single Issue',
        publisher: 'Image',
        releaseDate: DateTime.utc(2026, 1, 15),
        releaseYear: 2026,
        crossover: 'Event Prelude',
        plotSummary: 'Old summary',
        plotDescription: 'Old description',
        series: const CatalogSeriesDetails(
          seriesId: 'series-1',
          seriesTitle: 'Saga',
        ),
        storyArcs: const ['Opening'],
        genres: const ['Sci-Fi'],
        country: 'US',
        language: 'English',
        ageRating: 'Mature',
        publishing: const CatalogPublishingDetails(
          pageCount: 32,
          imprint: 'Skybound',
          seriesGroup: 'Saga Universe',
        ),
        synopsis: 'A long war begins.',
        trailerUrls: const [
          TrailerLink(
            url: 'https://example.com/original',
            title: 'Original link',
            isAutomatic: false,
          ),
        ],
      ),
    );
    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      editionId: 'edition-1',
      variantId: 'variant-1',
      quantity: 1,
      currency: 'USD',
      pricePaidCents: 499,
      personalNotes: 'Old personal note',
      ownerLabel: 'Andrei',
      purchaseStore: 'Old Shop',
      updatedAt: DateTime.utc(2026, 5, 30),
    );
    final trackingEntry = TrackingEntry(
      id: 'tracking-1',
      itemId: 'comic-1',
      ownedItemId: 'owned-1',
      editionId: 'edition-1',
      variantId: 'variant-1',
      sourceType: 'physical',
      status: 'Reading',
      rating: 7,
      notes: 'Tracking note',
      updatedAt: DateTime.utc(2026, 5, 30),
    );
    final customField = CustomFieldDefinition(
      id: 'cf-1',
      name: 'Signature note',
      fieldType: 'text',
      mediaKind: 'comic',
      createdAt: DateTime.utc(2026, 5, 30),
    );
    final customValue = CustomFieldValue(
      id: 'cfv-1',
      ownedItemId: 'owned-1',
      fieldDefinitionId: 'cf-1',
      value: 'First print',
      updatedAt: DateTime.utc(2026, 5, 30),
    );
    final request = LibraryEditDialogRequest(
      type: type,
      item: item,
      ownedItem: ownedItem,
      trackingEntry: trackingEntry,
      accent: Colors.red,
      customFieldDefinitions: [customField],
      customFieldValues: [customValue],
    );

    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => buildComicLibraryEditDialog(
                      context,
                      request,
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
    await pumpUntilSettled(tester);

    expect(find.byTooltip('Pick Series'), findsOneWidget);
    expect(find.byTooltip('Manage Series'), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);

    await tester.tap(find.byTooltip('Pick Series'));
    await tester.pumpAndSettle();

    expect(find.text('Over the Garden Wall'), findsOneWidget);

    await tester.tap(find.text('Over the Garden Wall'));
    await tester.pumpAndSettle();

    expect(find.text('Over the Garden Wall'), findsOneWidget);

    await tester.tap(find.byTooltip('Manage Series'));
    await tester.pumpAndSettle();

    expect(find.text('Select Series'), findsOneWidget);
    expect(find.text('New Series'), findsOneWidget);
    expect(find.text('Manage Series'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('edit-coverdate-year')),
      '2026',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-coverdate-month')),
      '01',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-coverdate-day')),
      '01',
    );

    await tester.tap(find.text('Details').last);
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.byKey(const ValueKey('edit-title')),
      'Saga Deluxe',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-crossover')),
      'Image United',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-storyarcs')),
      'Opening, Finale',
    );
    await tester.tap(find.text('Value').first);
    await pumpUntilSettled(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('edit-custom-label')));
    await tester.enterText(
      find.byKey(const ValueKey('edit-custom-label')),
      'Silver Foil',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-page-quality')),
      'White Pages',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('edit-key-major')));
    await tester.tap(find.byKey(const ValueKey('edit-key-major')));
    await pumpUntilSettled(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('edit-key-category')));
    await tester.enterText(
      find.byKey(const ValueKey('edit-key-category')),
      'Origin',
    );

    await tester.tap(find.text('Personal').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.byKey(const ValueKey('edit-status-finished')));
    await pumpUntilSettled(tester);
    await tester.tap(find.byKey(const ValueKey('edit-rating-choice-9')));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.byKey(const ValueKey('edit-read-date-year')),
      '2026',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-read-date-month')),
      '05',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-read-date-day')),
      '30',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-owner')),
      'Desk Box',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-notes')),
      'Shelf note',
    );

    await tester.ensureVisible(find.text('Plot').first);
    await tester.tap(find.text('Plot').first);
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.byKey(const ValueKey('edit-summary')),
      'Short summary',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-description')),
      'Long plot description',
    );

    await tester.tap(find.text('Custom Fields').last);
    await pumpUntilSettled(tester);
    expect(find.text('Signature note'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Signed in person');

    await tester.ensureVisible(find.text('Links').last);
    await tester.tap(find.text('Links').last);
    await pumpUntilSettled(tester);

    final existingUrlField = tester.widget<TextField>(
      find.byKey(const ValueKey('edit-link-0-url')),
    );
    expect(existingUrlField.controller?.text, 'https://example.com/original');

    await tester.tap(find.widgetWithText(FilledButton, 'Add Link'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.byKey(const ValueKey('edit-link-1-title')),
      'Review',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit-link-1-url')),
      'https://example.com/review',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection, isNotNull);
    expect(selection!.item.title, 'Saga Deluxe');
    expect(selection!.item.crossover, 'Image United');
    expect(selection!.item.storyArcs, ['Opening', 'Finale']);
    expect(selection!.item.coverDate, DateTime(2026, 1, 1));
    expect(selection!.item.synopsis, 'Short summary\n\nLong plot description');
    expect(selection!.item.plotSummary, 'Short summary');
    expect(selection!.item.plotDescription, 'Long plot description');
    expect(selection!.item.trailerUrls, hasLength(2));
    expect(
        selection!.item.trailerUrls.first.url, 'https://example.com/original');
    expect(selection!.item.trailerUrls.first.title, 'Original link');
    expect(selection!.item.trailerUrls.last.url, 'https://example.com/review');
    expect(selection!.item.trailerUrls.last.title, 'Review');
    expect(selection!.item.trailerUrls.last.isAutomatic, isFalse);
    expect(selection!.personal?.ownerLabel, 'Desk Box');
    expect(selection!.personal?.personalNotes, 'Shelf note');
    expect(selection!.personal?.customLabel, 'Silver Foil');
    expect(selection!.personal?.pageQuality, 'White Pages');
    expect(selection!.personal?.keyCategory, 'Origin');
    expect(selection!.personal?.keySeverity, 'Major');
    expect(selection!.tracking?.readStatus, 'Finished');
    expect(selection!.tracking?.rating, 9);
    expect(selection!.tracking?.finishedAt, DateTime(2026, 5, 30));
    expect(selection!.tracking?.notes, 'Tracking note');
    expect(selection!.customFieldEdits, {'cf-1': 'Signed in person'});
  });

  testWidgets(
      'comic edit dialog returns custom field and item image edits for real image changes',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const imageBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aS1cAAAAASUVORK5CYII=';

    final type = collectarrLibraryTypes.byKind('comic')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'comic-2',
        kind: 'comic',
        title: 'Paper Girls',
        itemNumber: '2',
      ),
    );
    final ownedItem = OwnedItem(
      id: 'owned-2',
      itemId: 'comic-2',
      editionId: 'edition-2',
      variantId: 'variant-2',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 5, 30),
    );
    final customField = CustomFieldDefinition(
      id: 'cf-2',
      name: 'Signing details',
      fieldType: 'text',
      mediaKind: 'comic',
      createdAt: DateTime.utc(2026, 5, 30),
    );
    final request = LibraryEditDialogRequest(
      type: type,
      item: item,
      ownedItem: ownedItem,
      accent: Colors.red,
      customFieldDefinitions: [customField],
    );

    LibraryEditSelection? selection;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  selection = await showDialog<LibraryEditSelection>(
                    context: context,
                    builder: (context) => buildComicLibraryEditDialog(
                      context,
                      request,
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
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Custom Fields').last);
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.byType(TextFormField),
      'Signed at con',
    );

    await tester.tap(find.text('My Images').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Paste base64 image'));
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      imageBase64,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection, isNotNull);
    expect(selection!.customFieldEdits, {'cf-2': 'Signed at con'});
    expect(selection!.itemImageEdits, hasLength(1));
    expect(selection!.itemImageEdits.single.imageData, imageBase64);
    expect(selection!.itemImageEdits.single.caption, isNull);
    expect(selection!.itemImageEdits.single.imageType, 'auxiliary');
    expect(selection!.itemImageEdits.single.deleted, isFalse);
  });
}
