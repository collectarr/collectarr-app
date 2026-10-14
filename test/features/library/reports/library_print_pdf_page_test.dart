import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_print_pdf_page.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures/test_constants.dart';
import '../../../support/builders/workspace_item_builder.dart';

void main() {
  testWidgets('print field dialogs apply selections and Cancel discards edits',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: LibraryPrintPdfPage(
      type: defaultLibraryKindRegistry.require(CatalogMediaKind.music),
      items: const [],
    )));
    await pumpUntilSettled(tester);
    final originalSummary =
        tester.widget<Text>(find.textContaining('Active columns (')).data!;
    final barcodeChoice = find.descendant(
      of: find.byType(LibraryFieldSelectionCheckbox),
      matching: find.text('Barcode'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Manage').first);
    await pumpUntilSettled(tester);
    await tester.tap(barcodeChoice);
    await tester.tap(find.text('Cancel'));
    await pumpUntilSettled(tester);
    expect(find.text(originalSummary), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Manage').first);
    await pumpUntilSettled(tester);
    await tester.tap(barcodeChoice);
    await tester.tap(find.text('Save'));
    await pumpUntilSettled(tester);
    expect(find.text(originalSummary), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Manage').last);
    await pumpUntilSettled(tester);
    final titleChoice = find.descendant(
      of: find.byType(LibraryFieldSelectionCheckbox),
      matching: find.text('Title'),
    );
    await tester.ensureVisible(titleChoice);
    await tester.tap(titleChoice);
    await tester.tap(find.text('Save'));
    await pumpUntilSettled(tester);
    final sortSection = find
        .ancestor(of: find.text('Sort Order'), matching: find.byType(Column))
        .first;
    expect(find.descendant(of: sortSection, matching: find.text('Title')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LibraryPrintPdfPage renders full layout with all CLZ sections',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final musicType =
        defaultLibraryKindRegistry.require(CatalogMediaKind.music);

    final track1 = MusicTrack(
      id: const MusicTrackId('track-1'),
      position: 'A1',
      title: 'Paranoid Android',
      durationMs: 383000,
    );
    final disc1 = MusicDisc(
      id: const MusicDiscId('disc-1'),
      discNumber: 1,
      format: 'CD',
      tracks: [track1],
    );
    final album1 = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
      title: 'OK Computer',
      artist: 'Radiohead',
      barcode: '724385522925',
      catalogNumber: 'CDNODATA02',
      discs: [disc1],
    );

    final entry1 = testLibraryWorkspaceSource(
      itemId: 'album-1',
      kind: 'music',
      title: 'OK Computer',
      catalogData: MusicWorkspaceData.fromMusic(album1),
    );

    final shelf = ShelfState(
      entries: [entry1],
      entryCount: 1,
      wishlistCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final items = libraryItemsForShelf(shelf, musicType);

    await tester.pumpWidget(
      MaterialApp(
        home: LibraryPrintPdfPage(
          type: musicType,
          items: items,
          allItems: items,
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Header
    expect(find.text('Print to PDF'), findsOneWidget);
    expect(find.byKey(const Key('print_pdf.back')), findsOneWidget);
    for (final label in ['Print to PDF', 'Back']) {
      expect(
          DefaultTextStyle.of(tester.element(find.text(label)))
              .style
              .fontFamily,
          appFontFamily,
          reason: label);
    }

    // Section 1: Subset
    expect(find.text('Which Albums'), findsOneWidget);
    expect(find.text('All Albums'), findsOneWidget);
    expect(find.text('Current List'), findsOneWidget);
    expect(find.text('Checkboxed'), findsOneWidget);

    // Section 1: Export Mode
    expect(find.text('Export mode'), findsOneWidget);
    expect(find.text('Album list'), findsOneWidget);
    expect(find.text('Track list'), findsOneWidget);

    // Section 1: Columns and Sort
    expect(find.text('Visible Columns'), findsOneWidget);
    expect(find.text('Sort Order'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Manage'), findsNWidgets(2));

    // Section 2: Page Setup
    expect(find.text('Page Setup'), findsOneWidget);
    expect(find.text('Portrait'), findsWidgets);
    expect(find.text('Landscape'), findsWidgets);
    expect(find.text('Wrap inside column'), findsOneWidget);
    expect(find.text('Cover thumbnails'), findsOneWidget);
    expect(find.text('More settings'), findsOneWidget);

    // Section 3: Paper Preview Mockup
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('OK Computer'), findsWidgets);
    expect(find.text('Radiohead'), findsWidgets);

    // Section 4: Action Bar
    final generateBtn = find.text('Generate PDF file');
    await tester.ensureVisible(generateBtn);
    expect(generateBtn, findsOneWidget);
  });

  testWidgets('LibraryPrintPdfPage toggles Export Mode to Track List',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final musicType =
        defaultLibraryKindRegistry.require(CatalogMediaKind.music);

    final track1 = MusicTrack(
      id: const MusicTrackId('track-1'),
      position: 'A1',
      title: 'Airbag',
      durationMs: 284000,
    );
    final disc1 = MusicDisc(
      id: const MusicDiscId('disc-1'),
      discNumber: 1,
      format: 'CD',
      tracks: [track1],
    );
    final album1 = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
      title: 'OK Computer',
      artist: 'Radiohead',
      discs: [disc1],
    );

    final entry1 = testLibraryWorkspaceSource(
      itemId: 'album-1',
      kind: 'music',
      title: 'OK Computer',
      catalogData: MusicWorkspaceData.fromMusic(album1),
    );

    final shelf = ShelfState(
      entries: [entry1],
      entryCount: 1,
      wishlistCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final items = libraryItemsForShelf(shelf, musicType);

    await tester.pumpWidget(
      MaterialApp(
        home: LibraryPrintPdfPage(
          type: musicType,
          items: items,
          allItems: items,
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Tap Track list
    await tester.tap(find.text('Track list'));
    await pumpUntilSettled(tester);

    // Track columns should be visible in preview
    expect(find.text('Airbag'), findsWidgets);
  });

  testWidgets('LibraryPrintPdfPage generates PDF file on click',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final musicType =
        defaultLibraryKindRegistry.require(CatalogMediaKind.music);

    final track1 = MusicTrack(
      id: const MusicTrackId('track-1'),
      position: '1',
      title: 'Karma Police',
      durationMs: 261000,
    );
    final disc1 = MusicDisc(
      id: const MusicDiscId('disc-1'),
      discNumber: 1,
      tracks: [track1],
    );
    final album1 = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
      title: 'OK Computer',
      artist: 'Radiohead',
      discs: [disc1],
    );

    final entry1 = testLibraryWorkspaceSource(
      itemId: 'album-1',
      kind: 'music',
      title: 'OK Computer',
      catalogData: MusicWorkspaceData.fromMusic(album1),
    );

    final shelf = ShelfState(
      entries: [entry1],
      entryCount: 1,
      wishlistCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    final items = libraryItemsForShelf(shelf, musicType);

    await tester.pumpWidget(
      MaterialApp(
        home: LibraryPrintPdfPage(
          type: musicType,
          items: items,
        ),
      ),
    );
    await pumpUntilSettled(tester);

    final generateBtn = find.text('Generate PDF file');
    await tester.ensureVisible(generateBtn);
    await tester.tap(generateBtn);
    await pumpUntilSettled(tester);

    // Should now show Download file and Print / Open
    expect(find.textContaining('Download file'), findsOneWidget);
    expect(find.text('Print / Open'), findsOneWidget);
  });
}
