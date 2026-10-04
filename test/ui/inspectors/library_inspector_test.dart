import 'dart:convert';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/book/inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/book/inspector/book_entity_inspector_contributors.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factories.dart';

LibraryProjection _emptyProjection() => const LibraryProjection(
      allItems: [],
      filteredItems: [],
      buckets: [],
      selectedItem: null,
      counts: LibraryToolbarCounts(),
    );

void main() {
  testWidgets('book work inspector contributor shows a creator spotlight', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final item = testProjectionItem(
      id: 'book-hero-1',
      kind: 'book',
      title: 'Hyperion',
      catalogItem: testCatalogItem(
        id: 'book-hero-1',
        kind: 'book',
        title: 'Hyperion',
        creators: const [
          {'name': 'Dan Simmons', 'role': 'Author'},
        ],
      ),
    );
    final request = LibraryInspectorRequest(
      type: const BookRegistration(),
      item: item,
      libraryEntry: null,
      accent: Colors.orange,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => buildBookWorkInspectorHero(
                context,
                request,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Author view'), findsOneWidget);
    expect(find.text('Dan Simmons'), findsOneWidget);
  });

  testWidgets('comic inspector hero renders CLZ-like header blocks', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ComicInspectorHero(
              request: LibraryInspectorRequest(
                type: const ComicRegistration(),
                item: testProjectionItem(
                  id: 'comic-hero-1',
                  kind: 'comic',
                  title: 'The Last Ronin',
                  barcode: '82771402051700111',
                ),
                libraryEntry: testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-comic-hero-1',
                  itemId: 'comic-hero-1',
                  isDigital: false,
                  condition: 'Near Mint',
                  grade: '9.8',
                  updatedAt: DateTime.utc(2026, 5, 23),
                )),
                accent: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('IDW'), findsWidgets);
    expect(find.textContaining('Director Cut'), findsOneWidget);
    expect(find.text('82771402051700111'), findsOneWidget);
    expect(find.text('Plot'), findsOneWidget);
    expect(find.byKey(const ValueKey('comic-inspector-slab-overlay')),
        findsNothing);
  });

  testWidgets('comic inspector hero lays out in a narrow scrollable inspector',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                SizedBox(
                  width: 664,
                  child: ComicInspectorHero(
                    request: LibraryInspectorRequest(
                      type: const ComicRegistration(),
                      item: testProjectionItem(
                        id: 'comic-hero-narrow-1',
                        kind: 'comic',
                        title: 'The Last Ronin',
                      ),
                      libraryEntry: testLibraryEntrySummary(testLibraryEntry(
                        id: 'entry-comic-hero-narrow-1',
                        itemId: 'comic-hero-narrow-1',
                        isDigital: false,
                        condition: 'Near Mint',
                        grade: '9.8',
                        updatedAt: DateTime.utc(2026, 5, 23),
                      )),
                      accent: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Director Cut'), findsOneWidget);
  });

  testWidgets('library inspector uses the comic-specific full panel hook', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final libraryEntry = testLibraryEntry(
      id: 'entry-comic-hero-2',
      itemId: 'comic-hero-2',
      kind: 'comic',
      isDigital: false,
      condition: 'Near Mint',
      grade: '9.8',
      coverPriceCents: 899,
      marketValueCents: 2499,
      pricePaidCents: 1299,
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      certificationNumber: '1234567890',
      keyComic: true,
      keyReason: 'First print finale',
      updatedAt: DateTime.utc(2026, 5, 23),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: const ComicRegistration(),
              projection: _emptyProjection(),
              item: testProjectionItem(
                id: 'comic-hero-2',
                kind: 'comic',
                title: 'The Last Ronin',
                libraryEntry: libraryEntry,
              ),
              libraryEntry: testLibraryEntrySummary(libraryEntry),
              libraryEntryDispatch: testComicLibraryEntryDispatchFrom(
                testComicLibraryEntryFrom(libraryEntry),
              ),
              entryCopies: [
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-comic-hero-2',
                  itemId: 'comic-hero-2',
                  isDigital: false,
                  condition: 'Near Mint',
                  grade: '9.8',
                  coverPriceCents: 899,
                  marketValueCents: 2499,
                  pricePaidCents: 1299,
                  rawOrSlabbed: 'Slabbed',
                  gradingCompany: 'CGC',
                  certificationNumber: '1234567890',
                  keyComic: true,
                  keyReason: 'First print finale',
                  updatedAt: DateTime.utc(2026, 5, 23),
                )),
              ],
              accent: Colors.red,
              onAddEntry: () {},
              onRemoveEntry: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (_) {},
              onDetailsLayoutChanged: (_) {},
              db: db,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ComicInspectorHero), findsOneWidget);
    expect(find.byKey(const ValueKey('comic-inspector-slab-overlay')),
        findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Collection tools'), findsNothing);
  });

  testWidgets('comic inspector keeps copy selection in the toolbar menu', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await ComicEntryRepository(db).upsertAll([
      testComicLibraryEntryFrom(testLibraryEntry(
        id: 'entry-comic-1',
        itemId: 'comic-multi-1',
        kind: 'comic',
        condition: 'Near Mint',
        updatedAt: DateTime.utc(2026, 5, 23, 10),
      )),
      testComicLibraryEntryFrom(testLibraryEntry(
        id: 'entry-comic-2',
        itemId: 'comic-multi-1',
        kind: 'comic',
        condition: 'Very Fine',
        updatedAt: DateTime.utc(2026, 5, 23, 11),
      )),
    ]);
    LibraryEntrySummary? editedLibraryEntry;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: const ComicRegistration(),
              projection: _emptyProjection(),
              item: testProjectionItem(
                id: 'comic-multi-1',
                kind: 'comic',
                title: 'The Last Ronin',
              ),
              libraryEntry: testLibraryEntrySummary(testLibraryEntry(
                id: 'entry-comic-1',
                itemId: 'comic-multi-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              )),
              entryCopies: [
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-comic-1',
                  itemId: 'comic-multi-1',
                  condition: 'Near Mint',
                  updatedAt: DateTime.utc(2026, 5, 23, 10),
                )),
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-comic-2',
                  itemId: 'comic-multi-1',
                  condition: 'Very Fine',
                  updatedAt: DateTime.utc(2026, 5, 23, 11),
                )),
              ],
              accent: Colors.red,
              onAddEntry: () {},
              onRemoveEntry: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (libraryEntry) => editedLibraryEntry = libraryEntry,
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(editedLibraryEntry, isNull);
    expect(find.text('Active copy'), findsOneWidget);
    expect(find.textContaining('copies in collection'), findsOneWidget);
  });

  testWidgets('book inspector keeps shared action primitives visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: BookInspectorPanel(
              request: LibraryInspectorPanelRequest(
                inspector: LibraryInspectorRequest(
                  type: const BookRegistration(),
                  item: testProjectionItem(
                    id: 'book-1',
                    kind: 'book',
                    title: 'Hyperion',
                  ),
                  libraryEntry: null,
                  accent: Colors.blue,
                ),
                hero: const SizedBox(height: 20),
                primarySections: const [SizedBox.shrink()],
                trailingSections: const [SizedBox.shrink()],
                entryCopies: const [],
                selectedLibraryEntryRef: null,
                extraActions: const [Text('Extra action')],
                onAddCopy: () {},
                onOpenDetails: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final actionBar = find.byType(InspectorActionBar);
    expect(find.descendant(of: actionBar, matching: find.text('Quick actions')),
        findsOneWidget);
    expect(find.descendant(of: actionBar, matching: find.text('Open')),
        findsOneWidget);
    expect(find.descendant(of: actionBar, matching: find.text('Edit')),
        findsOneWidget);
    expect(
        find.descendant(
            of: actionBar, matching: find.byIcon(Icons.fact_check_outlined)),
        findsNothing);
    expect(
        find.descendant(
            of: actionBar, matching: find.byIcon(Icons.open_in_new)),
        findsOneWidget);
    expect(find.text('Extra action'), findsOneWidget);
  });

  testWidgets('inspector section renders title and children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryDetailSection(
            title: 'Personal',
            children: [Text('Location')],
          ),
        ),
      ),
    );

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
  });

  testWidgets('inspector fact grid renders fact labels and values',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: LibraryDetailFieldTable(
              fields: [
                LibraryDetailField(label: 'Grade', value: '9.8'),
                LibraryDetailField(label: 'Condition', value: 'Near Mint'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grade'), findsOneWidget);
    expect(find.text('9.8'), findsOneWidget);
    expect(find.text('Condition'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
  });

  testWidgets('personal section shows cover price for Comic-entry details',
      (tester) async {
    final libraryEntry = testLibraryEntry(
      id: 'entry-1',
      itemId: 'comic-1',
      kind: 'comic',
      purchaseDate: DateTime.utc(2026, 5, 11),
      pricePaidCents: 1299,
      coverPriceCents: 1599,
      soldAt: DateTime.utc(2026, 5, 20),
      sellPriceCents: 1899,
      currency: 'USD',
      updatedAt: DateTime.utc(2026, 5, 22),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorPersonalSection(
            type: const ComicRegistration(),
            item: testProjectionItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Saga',
              libraryEntry: libraryEntry,
            ),
            libraryEntry: testLibraryEntrySummary(libraryEntry),
            libraryEntryDispatch: testComicLibraryEntryDispatchFrom(
              testComicLibraryEntryFrom(libraryEntry),
            ),
            accent: Colors.orange,
          ),
        ),
      ),
    );

    expect(find.text('Cover price'), findsOneWidget);
    expect(find.text('USD 15.99'), findsOneWidget);
    expect(find.text('Profit / Loss'), findsOneWidget);
    expect(find.text('USD 6.00'), findsOneWidget);
  });

  testWidgets(
      'personal section labels digital entries and hides physical-only facts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorPersonalSection(
            type: const MovieRegistration(),
            item: testProjectionItem(
              id: 'movie-1',
              kind: 'movie',
              title: 'Blade Runner 2049',
            ),
            libraryEntry: testLibraryEntrySummary(testLibraryEntry(
              id: 'entry-1',
              itemId: 'movie-1',
              isDigital: true,
              pricePaidCents: 1299,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            )),
            accent: Colors.orange,
          ),
        ),
      ),
    );

    expect(find.text('EntryPolicy'), findsOneWidget);
    expect(find.text('Digital copy'), findsOneWidget);
    expect(find.text('Condition'), findsNothing);
    expect(find.text('Grade'), findsNothing);
    expect(find.text('Storage'), findsNothing);
  });

  testWidgets('inspector action bar avoids overflow on narrow widths', (
    tester,
  ) async {
    const type = BookRegistration();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 356,
            child: InspectorActionBar(
              type: type,
              item: testProjectionItem(
                id: 'book-1',
                kind: 'book',
                title: 'The Fellowship of the Ring',
                libraryEntry: testLibraryEntry(
                  id: 'entry-1',
                  itemId: 'book-1',
                  kind: 'book',
                ),
              ),
              onToggleEntry: () {},
              onToggleWishlist: () {},
              onEdit: () {},
              onOpenDetails: () {},
              extraActions: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Entry'), findsOneWidget);
    expect(find.text('Wish list'), findsOneWidget);
  });

  testWidgets('book inspector hides the item images section', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const type = BookRegistration();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              projection: _emptyProjection(),
              item: testProjectionItem(
                id: 'book-1',
                kind: 'book',
                title: 'The Two Towers',
              ),
              libraryEntry: testLibraryEntrySummary(testLibraryEntry(
                id: 'entry-1',
                itemId: 'book-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              )),
              accent: Colors.orange,
              onAddEntry: () {},
              onRemoveEntry: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (_) {},
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.byType(InspectorItemImagesSection), findsNothing);
    expect(find.text('Author view'), findsOneWidget);
    expect(find.text('J.R.R. Tolkien'), findsWidgets);
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('item images section hides front cover thumbnails', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'front-1',
            libraryEntryRefKey: 'book:entry-1',
            imageType: const Value('front_cover'),
            imageData: base64Decode(base64Encode(const [0, 1, 2, 3])),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );
    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'back-1',
            libraryEntryRefKey: 'book:entry-1',
            imageType: const Value('back_cover'),
            imageData: base64Decode(base64Encode(const [4, 5, 6, 7])),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: InspectorItemImagesSection(
              libraryEntryRef: LibraryEntryRef.fromKey('book:entry-1'),
              db: db,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.byType(InspectorItemImagesSection), findsOneWidget);
    expect(find.text('Front Cover'), findsNothing);
  });

  testWidgets('inspector shows a copy selector when multiple copies exist', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const type = BookRegistration();
    await BookEntryRepository(db).upsertAll([
      testBookLibraryEntryFrom(testLibraryEntry(
        id: 'entry-1',
        itemId: 'book-1',
        kind: 'book',
        condition: 'Near Mint',
        updatedAt: DateTime.utc(2026, 5, 23, 10),
      )),
      testBookLibraryEntryFrom(testLibraryEntry(
        id: 'entry-2',
        itemId: 'book-1',
        kind: 'book',
        condition: 'Very Fine',
        updatedAt: DateTime.utc(2026, 5, 23, 11),
      )),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              projection: _emptyProjection(),
              item: testProjectionItem(
                id: 'book-1',
                kind: 'book',
                title: 'The Return of the King',
              ),
              libraryEntry: testLibraryEntrySummary(testLibraryEntry(
                id: 'entry-1',
                itemId: 'book-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              )),
              entryCopies: [
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-1',
                  itemId: 'book-1',
                  condition: 'Near Mint',
                  updatedAt: DateTime.utc(2026, 5, 23, 10),
                )),
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-2',
                  itemId: 'book-1',
                  condition: 'Very Fine',
                  updatedAt: DateTime.utc(2026, 5, 23, 11),
                )),
              ],
              accent: Colors.orange,
              onAddEntry: () {},
              onRemoveEntry: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (_) {},
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('2 copies in collection'), findsOneWidget);
    expect(find.text('Add copy'), findsOneWidget);
    expect(find.text('Active copy'), findsOneWidget);
  });

  testWidgets('inspector edit uses the selected copy', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const type = BookRegistration();
    await BookEntryRepository(db).upsertAll([
      testBookLibraryEntryFrom(testLibraryEntry(
        id: 'entry-1',
        itemId: 'book-1',
        kind: 'book',
        condition: 'Near Mint',
        updatedAt: DateTime.utc(2026, 5, 23, 10),
      )),
      testBookLibraryEntryFrom(testLibraryEntry(
        id: 'entry-2',
        itemId: 'book-1',
        kind: 'book',
        condition: 'Very Fine',
        updatedAt: DateTime.utc(2026, 5, 23, 11),
      )),
    ]);
    LibraryEntrySummary? editedLibraryEntry;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              projection: _emptyProjection(),
              item: testProjectionItem(
                id: 'book-1',
                kind: 'book',
                title: 'The Return of the King',
              ),
              libraryEntry: testLibraryEntrySummary(testLibraryEntry(
                id: 'entry-1',
                itemId: 'book-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              )),
              entryCopies: [
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-1',
                  itemId: 'book-1',
                  condition: 'Near Mint',
                  updatedAt: DateTime.utc(2026, 5, 23, 10),
                )),
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-2',
                  itemId: 'book-1',
                  condition: 'Very Fine',
                  updatedAt: DateTime.utc(2026, 5, 23, 11),
                )),
              ],
              accent: Colors.orange,
              onAddEntry: () {},
              onRemoveEntry: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (libraryEntry) => editedLibraryEntry = libraryEntry,
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    await tester.tap(find.byType(DropdownButtonFormField<LibraryEntryRef>).first);
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Copy 2').last);
    await pumpUntilSettled(tester);

    await tester.tap(
      find
          .descendant(
            of: find.byType(InspectorActionBar),
            matching: find.widgetWithText(OutlinedButton, 'Edit'),
          )
          .first,
    );
    await tester.pump();

    expect(editedLibraryEntry?.ref.id.value, 'entry-2');
  });

  testWidgets(
      'inspector hero switches local back-cover affordance with the selected copy',
      (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const type = BookRegistration();

    await BookEntryRepository(db).upsertAll([
      testBookLibraryEntryFrom(testLibraryEntry(
        id: 'entry-1',
        itemId: 'book-1',
        kind: 'book',
        condition: 'Near Mint',
        updatedAt: DateTime.utc(2026, 5, 23, 10),
      )),
      testBookLibraryEntryFrom(testLibraryEntry(
        id: 'entry-2',
        itemId: 'book-1',
        kind: 'book',
        condition: 'Very Fine',
        updatedAt: DateTime.utc(2026, 5, 23, 11),
      )),
    ]);
    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'back-entry-2',
            libraryEntryRefKey: 'book:entry-2',
            imageType: const Value('back_cover'),
            imageData: base64Decode('AQIDBA=='),
            createdAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              projection: _emptyProjection(),
              item: testProjectionItem(
                id: 'book-1',
                kind: 'book',
                title: 'The Return of the King',
              ),
              libraryEntry: testLibraryEntrySummary(testLibraryEntry(
                id: 'entry-1',
                itemId: 'book-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              )),
              entryCopies: [
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-1',
                  itemId: 'book-1',
                  condition: 'Near Mint',
                  updatedAt: DateTime.utc(2026, 5, 23, 10),
                )),
                testLibraryEntrySummary(testLibraryEntry(
                  id: 'entry-2',
                  itemId: 'book-1',
                  condition: 'Very Fine',
                  updatedAt: DateTime.utc(2026, 5, 23, 11),
                )),
              ],
              accent: Colors.orange,
              onAddEntry: () {},
              onRemoveEntry: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (_) {},
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.widgetWithText(FilledButton, 'Front'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Back'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<LibraryEntryRef>).first);
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Copy 2').last);
    await pumpUntilSettled(tester);

    expect(find.widgetWithText(FilledButton, 'Front'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Back'), findsNothing);
  });

  testWidgets('inspector toolbar uses the shared details layout dropdown',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorUnifiedToolbar(
            item: testProjectionItem(
              id: 'music-3',
              kind: 'music',
              title: 'The Black Parade',
            ),
            detailsLayout: LibraryDetailsLayout.right,
            onEdit: () {},
            onShare: () {},
            onDuplicate: () {},
            onToggleEntry: () {},
            onLoan: () {},
            onRefreshMetadata: () {},
            onDetailsLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(LibraryDetailsLayoutDropdown), findsOneWidget);
  });

  testWidgets(
      'inspector eBay action expands with width and collapses compactly',
      (tester) async {
    final wideToolbar = MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 420,
          child: InspectorUnifiedToolbar(
            item: testProjectionItem(
              id: 'music-ebay-wide',
              kind: 'music',
              title: 'The Black Parade',
              barcode: '1234567890123',
            ),
            detailsLayout: LibraryDetailsLayout.right,
            onEdit: () {},
            onShare: () {},
            onDuplicate: () {},
            onToggleEntry: () {},
            onLoan: () {},
            onRefreshMetadata: () {},
            onDetailsLayoutChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpWidget(wideToolbar);

    expect(find.widgetWithText(OutlinedButton, 'eBay'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

    final compactToolbar = MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 260,
          child: InspectorUnifiedToolbar(
            item: testProjectionItem(
              id: 'music-ebay-compact',
              kind: 'music',
              title: 'The Black Parade',
              barcode: '1234567890123',
            ),
            detailsLayout: LibraryDetailsLayout.right,
            onEdit: () {},
            onShare: () {},
            onDuplicate: () {},
            onToggleEntry: () {},
            onLoan: () {},
            onRefreshMetadata: () {},
            onDetailsLayoutChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpWidget(compactToolbar);

    expect(find.text('eBay'), findsNothing);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });
}
