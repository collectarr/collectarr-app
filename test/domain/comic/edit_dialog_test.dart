import 'dart:convert';
import 'dart:math' as math;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'comic edit dialog saves expanded comic payload and external links',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    final catalog = CatalogCacheRepository(db);
    final pickLists = PickListRepository(db);
    final seriesRegistry = SeriesRegistryRepository(db);
    addTearDown(db.close);

    final catalogItems = [
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
    ];
    await catalog.upsertAll(catalogItems);
    await seriesRegistry.captureCatalogItems(catalogItems);
    await pickLists.setValues(
      kCrossoverPickListName,
      ['Annihilation', 'Image United'],
      mediaKind: 'comic',
    );
    await pickLists.setValues(
      kStoryArcPickListName,
      ['Opening', 'Finale'],
      mediaKind: 'comic',
    );
    await pickLists.setValues(
      kCountryPickListName,
      ['US', 'Canada'],
      mediaKind: 'comic',
    );
    await pickLists.setValues(
      kLanguagePickListName,
      ['English', 'French'],
      mediaKind: 'comic',
    );
    await pickLists.setValues(
      kAgeRatingPickListName,
      ['Mature', 'Teen'],
      mediaKind: 'comic',
    );
    await pickLists.setValues(
      kGenrePickListName,
      ['Sci-Fi', 'Fantasy'],
      mediaKind: 'comic',
    );

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
    final ownedItem = testOwnedItem(
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
      catalogRef: testCatalogRef('comic-1', kind: 'comic'),
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
      targetId: 'owned-1',
      targetScope: CustomFieldTargetScope.ownedCopy,
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
    await tester.pumpAndSettle();

    // The dialog opens on the Details tab — navigate to Main for Series.
    await tester.tap(find.text('Main'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Pick Series'), findsOneWidget);
    expect(find.byTooltip('Select or manage series'), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);

    await tester.tap(find.byTooltip('Pick Series'));
    await tester.pumpAndSettle();

    expect(find.text('Over the Garden Wall'), findsOneWidget);

    await tester.tap(find.text('Over the Garden Wall'));
    await tester.pumpAndSettle();

    expect(find.text('Over the Garden Wall'), findsOneWidget);

    await tester.tap(find.byTooltip('Select or manage series'));
    await tester.pumpAndSettle();

    expect(find.text('Select Series'), findsOneWidget);
    expect(find.text('New Series'), findsOneWidget);
    expect(find.text('Manage Series'), findsOneWidget);

    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('comic-cover-date-year')),
      '2026',
    );
    await tester.enterText(
      find.byKey(const ValueKey('comic-cover-date-month')),
      '01',
    );
    await tester.enterText(
      find.byKey(const ValueKey('comic-cover-date-day')),
      '01',
    );
    await tester.tap(find.text('Details').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.byTooltip('Pick Crossover'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Image United').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Pick Story Arc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finale').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Pick Country'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Canada').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Language'),
      'French',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Age'),
      'Teen',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Genre'),
      'Sci-Fi, Fantasy',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Saga Deluxe',
    );

    await tester.tap(find.text('Custom Fields').last);
    await pumpUntilSettled(tester);
    expect(find.text('Signature note'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Signature note'),
      'Signed in person',
    );

    await tester.ensureVisible(find.text('Links').last);
    await tester.tap(find.text('Links').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'New Link'));
    await pumpUntilSettled(tester);
    final linkFields = find.descendant(
      of: find.byType(ReorderableListView),
      matching: find.byType(TextFormField),
    );
    final linkFieldCount = linkFields.evaluate().length;
    await tester.enterText(
      linkFields.at(linkFieldCount - 2),
      'https://example.com/review',
    );
    await tester.enterText(
      linkFields.at(linkFieldCount - 1),
      'Review',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(selection, isNotNull);
    expect(selection!.item.title, 'Saga Deluxe');
    expect(selection!.item.crossover, 'Image United');
    expect(selection!.item.storyArcs, ['Finale']);
    expect(selection!.item.country, 'Canada');
    expect(selection!.item.language, 'French');
    expect(selection!.item.ageRating, 'Teen');
    expect(selection!.item.genres, ['Sci-Fi', 'Fantasy']);
    expect(selection!.item.coverDate, DateTime(2026, 1, 1));
    expect(selection!.item.trailerUrls, hasLength(2));
    expect(
        selection!.item.trailerUrls.first.url, 'https://example.com/original');
    expect(selection!.item.trailerUrls.first.title, 'Original link');
    expect(selection!.item.trailerUrls.last.url, 'https://example.com/review');
    expect(selection!.item.trailerUrls.last.title, 'Review');
    expect(selection!.item.trailerUrls.last.isAutomatic, isFalse);
    expect(selection!.customFieldEdits, {'cf-1': 'Signed in person'});
  });

  testWidgets(
      'comic edit dialog restores saved tab order',
      (tester) async {
    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'edit_tab_order_comic': ['9', '0', '1', '2', '3', '4', '5', '6', '7', '8', '10'],
    });

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final type = collectarrLibraryTypes.byKind('comic')!;
    final item = LibraryMetadataItem.fromCatalogItem(
      CatalogItem(
        id: 'comic-restore-order',
        kind: 'comic',
        title: 'Saga',
        itemNumber: '1',
      ),
    );
    final ownedItem = testOwnedItem(
      id: 'owned-restore-order',
      itemId: 'comic-restore-order',
      editionId: 'edition-restore-order',
      variantId: 'variant-restore-order',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 5, 30),
    );
    final request = LibraryEditDialogRequest(
      type: type,
      item: item,
      ownedItem: ownedItem,
      accent: Colors.red,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () {
                  showDialog<LibraryEditSelection>(
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
    await tester.pumpAndSettle();

    double leftMostDxForTopLabel(String label) {
      final finder = find.text(label);
      final count = finder.evaluate().length;
      expect(count, greaterThan(0));
      final points = <Offset>[
        for (var index = 0; index < count; index++)
          tester.getTopLeft(finder.at(index)),
      ];
      final topY = points.map((point) => point.dy).reduce(math.min);
      final topRowPoints =
          points.where((point) => (point.dy - topY).abs() < 1).toList();
      return topRowPoints.map((point) => point.dx).reduce(math.min);
    }

    final plotDx = leftMostDxForTopLabel('Plot');
    final detailsDx = leftMostDxForTopLabel('Details');
    expect(
      plotDx,
      lessThan(detailsDx),
    );
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
    final ownedItem = testOwnedItem(
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
      find.widgetWithText(TextFormField, 'Signing details'),
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
    expect(
      selection!.itemImageEdits.single.imageData,
      orderedEquals(base64Decode(imageBase64)),
    );
    expect(selection!.itemImageEdits.single.caption, isNull);
    expect(selection!.itemImageEdits.single.imageType, 'auxiliary');
    expect(selection!.itemImageEdits.single.deleted, isFalse);
  });
}
