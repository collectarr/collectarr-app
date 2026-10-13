import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/duplicates/library_duplicate_removal_plan.dart';
import 'package:collectarr_app/features/library/duplicates/library_find_duplicates_page.dart';
import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

LibraryWorkspaceContext entry(String id, int day,
    {String title = 'Deluxe Edition',
    String artist = 'Artist',
    String barcode = '12345',
    int index = 1}) {
  final ref =
      LibraryEntryRef(kind: CatalogMediaKind.music, id: LibraryEntryId(id));
  final album = MusicAlbum(title: title, artist: artist, barcode: barcode);
  return LibraryWorkspaceContext(
    item: WorkspaceItem(
      target: EntryTargetRef(ref),
      entrySummary:
          LibraryEntrySummary(ref: ref, createdAt: DateTime.utc(2026, 1, day)),
      kindPresentationData: MusicWorkspaceData.fromMusic(album),
      libraryEntryDispatch: OpaqueLibraryEntryDispatch(
          ref: ref,
          kind: CatalogMediaKind.music,
          value: MusicLibraryEntry(
              id: ref.id,
              metadata: album,
              personal: MusicPersonalData(indexNumber: index),
              updatedAt: DateTime.utc(2026))),
    ),
    personal: PersonalOverlay(),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
      'explicit criteria use their matching fields and ignore empty identifiers',
      () {
    final entries = [
      entry('a', 1),
      entry('b', 2),
      entry('c', 3, title: 'Other', barcode: '54321', index: 2)
    ];
    for (final criterion in LibraryDuplicateCriterion.values
        .where((c) => c != LibraryDuplicateCriterion.automatic)) {
      final groups = findDuplicateShelfGroups(entries, criterion: criterion);
      expect(groups, hasLength(1), reason: criterion.name);
      expect(groups.single.entries.map((e) => e.itemId), ['a', 'b']);
    }
    expect(
        findDuplicateShelfGroups(
            [entry('a', 1, barcode: ''), entry('b', 2, barcode: '')],
            criterion: LibraryDuplicateCriterion.identifier),
        isEmpty);
    expect(
        findDuplicateShelfGroups(
            [entry('a', 1), entry('b', 2, artist: 'Another')],
            criterion: LibraryDuplicateCriterion.titleAndCreator),
        isEmpty);
  });

  test('automatic removal preserves oldest and protected overlapping groups',
      () {
    final a = entry('a', 1), b = entry('b', 2), c = entry('c', 3);
    LibraryDuplicateGroup group(
            String key, List<LibraryWorkspaceContext> entries) =>
        LibraryDuplicateGroup(
            key: key,
            label: key,
            reason: 'Same title',
            confidenceScore: 70,
            entries: entries);
    final groups = [
      group('title', [c, b, a]),
      group('barcode', [c, b])
    ];
    expect(planDuplicateRemovals(groups).map((e) => e.itemId), ['c']);
    expect(planDuplicateRemovals(groups, keptGroupKeys: {'barcode'}), isEmpty);
    expect(
        planDuplicateRemovals([
          group('title', [b, a])
        ]).map((e) => e.itemId),
        ['b']);
  });

  testWidgets(
      'dedicated page finds groups, protects them, then removes confirmed duplicates',
      (tester) async {
    final removed = <String>[];
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: LibraryFindDuplicatesPage(
      type: libraryKindRegistrationForKind(CatalogMediaKind.music),
      accent: Colors.orange,
      entries: [entry('new', 2), entry('old', 1)],
      onRemove: (entry) async => removed.add(entry.itemId),
    ))));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.byKey(const Key('duplicates.find')));
    await tester.pumpAndSettle();
    expect(find.text('1 duplicate groups found'), findsOneWidget);
    final keep = find.widgetWithText(OutlinedButton, 'Keep 2');
    await tester.ensureVisible(keep);
    await tester.tap(keep);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const Key('duplicates.remove_all')))
            .onPressed,
        isNull);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Keeping 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('duplicates.remove_all')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(removed, ['new']);
    expect(find.text('No duplicates found.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('results and column selection resize without overflow',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: LibraryFindDuplicatesPage(
      type: libraryKindRegistrationForKind(CatalogMediaKind.music),
      accent: Colors.orange,
      entries: [entry('a', 1), entry('b', 2)],
    ))));
    await tester.tap(find.byKey(const Key('duplicates.find')));
    for (final width in [1400.0, 900.0, 480.0]) {
      tester.view.physicalSize = Size(width, 650);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Select Column Fields'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
  });
}
