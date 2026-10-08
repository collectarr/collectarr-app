import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_export_csv_txt_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';
import '../../../helpers/test_data_factories.dart';

void main() {
  testWidgets('LibraryExportCsvTxtPage renders full layout and controls',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
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
        home: LibraryExportCsvTxtPage(
          type: musicType,
          items: items,
          allItems: items,
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Header checks
    expect(find.text('Export to CSV / TXT'), findsOneWidget);
    expect(find.text('Export albums to CSV / TXT: Albums'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Section: Which Albums
    expect(find.text('Which Albums'), findsOneWidget);
    expect(find.text('All Albums'), findsOneWidget);
    expect(find.text('Current List'), findsOneWidget);
    expect(find.text('Checkboxed'), findsOneWidget);

    // Section: Export Mode
    expect(find.text('Export mode'), findsOneWidget);
    expect(find.text('Album list'), findsOneWidget);
    expect(find.text('Track list'), findsOneWidget);

    // Section: Visible Columns & Sort Order
    expect(find.text('Visible Columns'), findsOneWidget);
    expect(find.text('Sort Order'), findsOneWidget);

    // Section: Filetype Tabs
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('TXT'), findsOneWidget);

    // Section 1: Settings
    expect(find.text('1. Settings'), findsOneWidget);
    expect(find.text('Field Delimiter'), findsOneWidget);
    expect(find.text('Semicolon'), findsOneWidget);
    expect(find.text('Comma'), findsOneWidget);
    expect(find.text('Tab'), findsOneWidget);
    expect(find.text('Space'), findsOneWidget);
    expect(find.text('Field Enclosure'), findsOneWidget);
    expect(find.text('Double Quote'), findsOneWidget);
    expect(find.text('Single Quote'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(find.text('Include Field Names as First Row'), findsOneWidget);
    expect(find.text('Filename'), findsOneWidget);
    expect(find.text('.csv'), findsOneWidget);

    // Action buttons
    expect(find.text('Generate file'), findsOneWidget);
    await tester.ensureVisible(find.text('Generate file'));
    await tester.tap(find.text('Generate file'));
    await pumpUntilSettled(tester);

    expect(find.textContaining('Download file'), findsOneWidget);
    expect(find.text('Copy to clipboard'), findsOneWidget);

    // Section 4: Preview
    expect(find.text('4. Preview'), findsOneWidget);
    expect(find.textContaining('OK Computer'), findsWidgets);
    expect(find.textContaining('Radiohead'), findsWidgets);
  });

  testWidgets('LibraryExportCsvTxtPage tab switching and settings update preview',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
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
        home: LibraryExportCsvTxtPage(
          type: musicType,
          items: items,
          allItems: items,
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Switch to TXT tab
    await tester.tap(find.text('TXT'));
    await pumpUntilSettled(tester);

    // Filename extension badge should now show .txt
    expect(find.text('.txt'), findsOneWidget);

    // Switch to Track list export mode
    await tester.tap(find.text('Track list'));
    await pumpUntilSettled(tester);

    expect(find.text('Export albums to CSV / TXT: Tracks'), findsOneWidget);
    expect(find.textContaining('Paranoid Android'), findsWidgets);

    // Open Visible Columns manager
    final manageButtons = find.widgetWithText(OutlinedButton, 'Manage');
    expect(manageButtons, findsWidgets);
    await tester.tap(manageButtons.first);
    await pumpUntilSettled(tester);

    expect(find.text('Manage Visible Columns'), findsOneWidget);
    // Close modal
    await tester.tap(find.text('Cancel'));
    await pumpUntilSettled(tester);
  });
}
