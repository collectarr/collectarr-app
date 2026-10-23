import 'package:collectarr_app/features/library/workspace/tiles/library_card_footer.dart';
import 'dart:ui' as ui;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_row.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _selected = Color(0xff2a7fd4);
const _probe = Key('probe');

LibraryProjectionItem _item({String? collectionStatus}) {
  final entry = MusicLibraryEntry(
    id: const LibraryEntryId('a'),
    sourceCatalogRef:
        const CatalogItemRef(kind: CatalogMediaKind.music, id: 'catalog-a'),
    updatedAt: DateTime.utc(2026, 10, 10),
    personal:
        MusicPersonalData(indexNumber: 1, collectionStatus: collectionStatus),
    metadata: MusicAlbum(title: 'Album'),
  );
  final summary = MusicLibraryEntryProjection.toSummary(entry);
  return LibraryProjectionItem.fromShelf(
    LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: EntryTargetRef(summary.ref),
        entrySummary: summary,
        libraryEntryDispatch: OpaqueLibraryEntryDispatch(
            ref: summary.ref, kind: CatalogMediaKind.music, value: entry),
        kindPresentationData: MusicWorkspaceData.fromMusic(entry.metadata),
      ),
      personal: const PersonalOverlay(),
    ),
    const MusicRegistration(),
  );
}

/// Hovers [target], clicks it (which selects it) and returns the colour of
/// the pixel at [probe], relative to the target's top left, with the mouse
/// still over it.
Future<Color> _colorAfterClick(
    WidgetTester tester, Finder target, Offset probe) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(target));
  await tester.pumpAndSettle();
  await mouse.down(tester.getCenter(target));
  await tester.pump();
  await mouse.up();
  await tester.pumpAndSettle();
  // Let the double-tap window close so no gesture timer is left pending.
  await tester.pump(kDoubleTapTimeout);

  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_probe));
  final origin = boundary.localToGlobal(Offset.zero);
  final at = tester.getTopLeft(target) + probe - origin;
  final pixels = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  }))!;
  final offset =
      (at.dy.round() * boundary.size.width.round() + at.dx.round()) * 4;
  return Color.fromARGB(
    pixels.getUint8(offset + 3),
    pixels.getUint8(offset),
    pixels.getUint8(offset + 1),
    pixels.getUint8(offset + 2),
  );
}

Widget _host(
  LocalDatabase db,
  Widget Function(bool selected, VoidCallback select) builder,
) {
  var selected = false;
  return ProviderScope(
    overrides: [localDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => Center(
            child: RepaintBoundary(
              key: _probe,
              child: builder(selected, () => setState(() => selected = true)),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final width in [160.0, 240.0]) {
    testWidgets('card footer reserves value and status space at $width px',
        (tester) async {
      const platform = 'A very long platform name that needs truncation';
      const value = 'CIB | USD 12345.67';
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  width: width,
                  height: 24,
                  child: const LibraryCardFooter(
                      label: platform,
                      value: value,
                      selected: false,
                      status: SizedBox(
                          key: ValueKey('status'), width: 21, height: 21))))));
      final labelBox = tester.getRect(find.text(platform));
      final valueBox = tester.getRect(find.text(value));
      final statusBox = tester.getRect(find.byKey(const ValueKey('status')));
      expect(labelBox.right, lessThanOrEqualTo(valueBox.left));
      expect(valueBox.right, lessThanOrEqualTo(statusBox.left));
      expect(tester.widget<Text>(find.text(platform)).overflow,
          TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'a horizontal card shorter than its text clips instead of overflowing',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = _item();
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 60,
              child: LibraryWorkspaceCard(
                item: item,
                customFieldBadges: const ['Signed', 'First press'],
                selected: selected,
                selectedColor: _selected,
                onTap: select,
              ),
            )));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a card clicked under the mouse shows its selection colour',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = _item();
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 88,
              child: LibraryWorkspaceCard(
                item: item,
                selected: selected,
                selectedColor: _selected,
                onTap: select,
              ),
            )));
    await tester.pumpAndSettle();

    final color = await _colorAfterClick(
        tester, find.byType(LibraryWorkspaceCard), const Offset(250, 70));

    expect(color, _selected);
    // Unmount before the database closes so its query timers finish.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a list row clicked under the mouse shows its selection colour',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 30,
              child: LibraryTableInkRow(
                density: LibraryDensity.comfortable,
                selected: selected,
                odd: false,
                onTap: select,
                selectedColor: _selected,
                oddColor: Colors.grey,
                evenColor: Colors.grey,
                selectionRailColor: _selected,
                bottomBorderColor: Colors.grey,
                hoverColor: const Color(0xff464950),
                child: const SizedBox(height: 28),
              ),
            )));
    await tester.pumpAndSettle();

    final color = await _colorAfterClick(
        tester, find.byType(LibraryTableInkRow), const Offset(200, 14));

    expect(color, _selected);
  });

  testWidgets('a card shows the collection status of its entry',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = _item(collectionStatus: 'For Sale');
    await tester.pumpWidget(_host(
        db,
        (selected, select) => SizedBox(
              width: 400,
              height: 88,
              child: LibraryWorkspaceCard(
                  item: item, selected: false, onTap: select),
            )));
    await tester.pumpAndSettle();

    expect(
        tester
            .widget<LibraryCollectionStatusIcon>(
                find.byType(LibraryCollectionStatusIcon))
            .collectionStatus,
        LibraryCollectionStatusScope.forSale);
    expect(find.byTooltip('For Sale'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
