import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/generic/page/collection_tabs.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late LibraryCollectionRepository repo;
  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repo = LibraryCollectionRepository(db);
  });
  tearDown(() => db.close());
  Future<LibraryEntryRef> entry(String id,
      {CatalogMediaKind kind = CatalogMediaKind.music}) async {
    await db.into(db.libraryEntries).insert(LibraryEntriesCompanion.insert(
        id: id,
        kind: kind.apiValue,
        payloadJson: '{}',
        updatedAt: DateTime.utc(2026)));
    final ref = LibraryEntryRef(kind: kind, id: LibraryEntryId(id));
    await repo.assignNewEntry(ref);
    return ref;
  }

  test(
      'collections own exclusive membership, counts and destinations for new entries',
      () async {
    final album = await entry('album');
    final main = (await repo.watch('music').first).single;
    final vinyl = await repo.create('music', 'Vinyl');
    expect(vinyl.count, 0);
    await repo.move([album], vinyl.id);
    var collections = await repo.watch('music').first;
    expect(collections.firstWhere((c) => c.id == main.id).count, 0);
    expect(collections.firstWhere((c) => c.id == vinyl.id).entryIds, {'album'});
    await repo.activate(vinyl.id);
    final newAlbum = await entry('new-album');
    await repo.assignNewEntry(album);
    collections = await repo.watch('music').first;
    expect(collections.firstWhere((c) => c.id == vinyl.id).entryIds,
        {album.id.value, newAlbum.id.value});
    expect(activeLibraryCollectionId(collections), vinyl.id);
  });

  test('batch moves validate all entries and roll back cross-kind requests',
      () async {
    final album = await entry('album');
    final book = await entry('book', kind: CatalogMediaKind.book);
    final vinyl = await repo.create('music', 'Vinyl');
    await expectLater(repo.move([album, book], vinyl.id), throwsArgumentError);
    expect(
        (await repo.watch('music').first)
            .firstWhere((c) => c.id == vinyl.id)
            .count,
        0);
    expect((await repo.watch('book').first).single.count, 1);
  });

  test(
      'delete transfers membership and active selection without deleting albums',
      () async {
    final album = await entry('album');
    final main = (await repo.watch('music').first).single;
    final vinyl = await repo.create('music', 'Vinyl');
    await repo.move([album], vinyl.id);
    await repo.activate(vinyl.id);
    await repo.delete(vinyl.id, moveTo: main.id);
    final remaining = (await repo.watch('music').first).single;
    expect(remaining.entryIds, {'album'});
    expect(remaining.isActive, isTrue);
    expect(await db.select(db.libraryEntries).get(), hasLength(1));
    await expectLater(
        repo.delete(main.id, moveTo: main.id), throwsArgumentError);
  });

  test('names and reordering are strict and kind isolated', () async {
    await repo.ensureDefault('music');
    final vinyl = await repo.create('music', 'Vinyl');
    final main = (await repo.list('music')).first;
    await repo.rename(vinyl.id, 'LPs');
    await expectLater(repo.create('music', 'lps'), throwsArgumentError);
    await expectLater(repo.rename(vinyl.id, '  '), throwsArgumentError);
    await expectLater(
        repo.reorder('music', [vinyl.id, vinyl.id]), throwsArgumentError);
    await repo.reorder('music', [vinyl.id, main.id]);
    expect((await repo.list('music')).map((c) => c.name),
        ['LPs', 'Main Collection']);
  });

  testWidgets(
      'manager creates, cancels rename and deletes into another collection on narrow screens',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() => repo.ensureDefault('music'));
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
                body: LibraryCollectionTabBar(
                    mediaKind: 'music',
                    accent: Colors.orange,
                    onCollectionSelected: (_) {})))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('library-collection-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create new collection'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Vinyl');
    await tester.tap(find.text('Create'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    final vinyl = (await tester.runAsync(() => repo.list('music')))!
        .singleWhere((c) => c.name == 'Vinyl');
    final mainId = (await tester.runAsync(() => repo.list('music')))!.first.id;
    final start =
        tester.getCenter(find.byKey(ValueKey('collection-drag-$mainId')));
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(start + const Offset(0, 24));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.moveTo(start + const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(
        (await tester.runAsync(() => repo.list('music')))!.first.id, vinyl.id);
    await tester.tap(find.descendant(
        of: find.byKey(ValueKey(vinyl.id)),
        matching: find.byTooltip('Rename collection')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Unsaved name');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: find.byKey(ValueKey(vinyl.id)), matching: find.text('Vinyl')),
        findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byKey(ValueKey(vinyl.id)),
        matching: find.byTooltip('Delete collection')));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Main Collection').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect((await tester.runAsync(() => repo.list('music')))!, hasLength(1));
    expect(find.byTooltip('Keep at least one collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
      'collection tabs select real collections and open a compact manager',
      (tester) async {
    final vinyl = (await tester.runAsync(() async {
      await repo.ensureDefault('music');
      return repo.create('music', 'Vinyl');
    }))!;
    LibraryCollectionSummary? selected;
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
                body: Align(
                    alignment: Alignment.bottomCenter,
                    child: LibraryCollectionTabBar(
                        mediaKind: 'music',
                        accent: Colors.orange,
                        onCollectionSelected: (value) => selected = value))))));
    await tester.pumpAndSettle();
    expect(find.text('Main Collection'), findsOneWidget);
    await tester.tap(find.text('Vinyl'));
    await tester.pumpAndSettle();
    expect(selected?.id, vinyl.id);
    await tester.tap(find.byKey(const ValueKey('library-collection-add')));
    await tester.pumpAndSettle();
    expect(find.text('Manage Collections'), findsOneWidget);
    expect(find.text('Create new collection'), findsOneWidget);
    expect(find.text('Private'), findsNWidgets(2));
    expect(find.textContaining('sort:'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
