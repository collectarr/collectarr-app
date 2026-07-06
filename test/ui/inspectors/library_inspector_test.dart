import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_hero.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/book/inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  testWidgets(
      'inspector hero shows a creator spotlight when the type enables it', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: InspectorHero(
              type: collectarrLibraryTypes.byKind('book')!,
              entry: LibraryWorkspaceEntry(
                id: 'book-hero-1',
                mediaType: 'book',
                title: 'Hyperion',
                creators: const [
                  {
                    'name': 'Dan Simmons',
                    'role': 'Author',
                  },
                ],
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: null,
              accent: Colors.orange,
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
                type: comicsLibraryConfig,
                entry: LibraryWorkspaceEntry(
                  id: 'comic-hero-1',
                  mediaType: 'comic',
                  title: 'The Last Ronin',
                  itemNumber: '1',
                  publisher: 'IDW Publishing',
                  releaseYear: 2020,
                  barcode: '82771402051700111',
                  synopsis:
                      'The final turtle seeks justice in a ruined future.',
                  series: CatalogSeriesDetails(
                    seriesTitle: 'Teenage Mutant Ninja Turtles: The Last Ronin',
                  ),
                  publishing: CatalogPublishingDetails(
                    imprint: 'IDW',
                    subtitle: 'Director Cut',
                    seriesGroup: 'TMNT Event',
                  ),
                  genres: const ['Action', 'Dystopian'],
                  updatedAt: DateTime.utc(2026, 5, 23),
                ),
                ownedItem: testOwnedItem(
                  id: 'owned-comic-hero-1',
                  itemId: 'comic-hero-1',
                  isDigital: false,
                  condition: 'Near Mint',
                  grade: '9.8',
                  updatedAt: DateTime.utc(2026, 5, 23),
                ),
                trackingEntry: null,
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
                      type: comicsLibraryConfig,
                      entry: LibraryWorkspaceEntry(
                        id: 'comic-hero-narrow-1',
                        mediaType: 'comic',
                        title: 'The Last Ronin',
                        itemNumber: '1',
                        publisher: 'IDW Publishing',
                        releaseYear: 2020,
                        barcode: '82771402051700111',
                        synopsis:
                            'The final turtle seeks justice in a ruined future.',
                        series: CatalogSeriesDetails(
                          seriesTitle:
                              'Teenage Mutant Ninja Turtles: The Last Ronin',
                        ),
                        publishing: CatalogPublishingDetails(
                          imprint: 'IDW',
                          subtitle: 'Director Cut',
                          seriesGroup: 'TMNT Event',
                        ),
                        isOwned: true,
                        updatedAt: DateTime.utc(2026, 5, 23),
                      ),
                      ownedItem: testOwnedItem(
                        id: 'owned-comic-hero-narrow-1',
                        itemId: 'comic-hero-narrow-1',
                        isDigital: false,
                        condition: 'Near Mint',
                        grade: '9.8',
                        updatedAt: DateTime.utc(2026, 5, 23),
                      ),
                      trackingEntry: null,
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
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: comicsLibraryConfig,
              entry: LibraryWorkspaceEntry(
                id: 'comic-hero-2',
                mediaType: 'comic',
                title: 'The Last Ronin',
                itemNumber: '1',
                publisher: 'IDW Publishing',
                releaseYear: 2020,
                barcode: '82771402051700111',
                synopsis: 'The final turtle seeks justice in a ruined future.',
                creators: const [
                  {'name': 'Kevin Eastman', 'role': 'Writer'},
                ],
                characters: const ['Michelangelo'],
                storyArcs: const ['The Last Ronin'],
                series: CatalogSeriesDetails(
                  seriesTitle: 'Teenage Mutant Ninja Turtles: The Last Ronin',
                ),
                publishing: CatalogPublishingDetails(
                  imprint: 'IDW',
                  subtitle: 'Director Cut',
                  seriesGroup: 'TMNT Event',
                ),
                genres: const ['Action', 'Dystopian'],
                isOwned: true,
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: testOwnedItem(
                id: 'owned-comic-hero-2',
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
              ),
              accent: Colors.red,
              onAddOwned: () {},
              onRemoveOwned: () {},
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

    expect(find.byType(ComicInspectorPanel), findsOneWidget);
    expect(find.byType(ComicInspectorHero), findsOneWidget);
    expect(find.byKey(const ValueKey('comic-inspector-slab-overlay')),
        findsOneWidget);
    expect(find.text('Quick actions'), findsNothing);
    expect(find.text('Collect'), findsNothing);
    expect(find.text('Remove'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Collection tools'), findsNothing);

    expect(find.byType(ComicInspectorPanel), findsOneWidget);
  });

  testWidgets('comic inspector keeps copy selection in the toolbar menu', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-comic-1',
            itemId: 'comic-multi-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 23, 10),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-comic-2',
            itemId: 'comic-multi-1',
            condition: const Value('Very Fine'),
            updatedAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );
    OwnedItem? editedOwnedItem;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: comicsLibraryConfig,
              entry: LibraryWorkspaceEntry(
                id: 'comic-multi-1',
                mediaType: 'comic',
                title: 'The Last Ronin',
                ownedItemId: 'owned-comic-1',
                isOwned: true,
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: testOwnedItem(
                id: 'owned-comic-1',
                itemId: 'comic-multi-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              ),
              accent: Colors.red,
              onAddOwned: () {},
              onRemoveOwned: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (ownedItem) => editedOwnedItem = ownedItem,
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(editedOwnedItem, isNull);
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
                  type: booksLibraryConfig,
                  entry: LibraryWorkspaceEntry(
                    id: 'book-1',
                    mediaType: 'book',
                    title: 'Hyperion',
                    updatedAt: DateTime.utc(2026, 5, 23),
                  ),
                  ownedItem: null,
                  accent: Colors.blue,
                  trackingEntry: null,
                ),
                hero: const SizedBox(height: 20),
                primarySections: const [SizedBox.shrink()],
                trailingSections: const [SizedBox.shrink()],
                ownedCopies: const [],
                selectedOwnedItemId: null,
                extraActions: const [Text('Extra action')],
                onAddCopy: () {},
                onOpenDetails: () {},
                onCorrectMetadata: () {},
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
    expect(find.descendant(of: actionBar, matching: find.byIcon(Icons.fact_check_outlined)),
        findsOneWidget);
    expect(find.text('Extra action'), findsOneWidget);
  });

  testWidgets('inspector section renders title and children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryInspectorSection(
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
            child: LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData('Grade', '9.8'),
                LibraryInspectorFactData('Condition', 'Near Mint'),
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

  testWidgets('personal section shows cover price for non-comic items',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorPersonalSection(
            entry: LibraryWorkspaceEntry(
              id: 'movie-1',
              mediaType: 'movie',
              title: 'Blade Runner 2049',
              pricePaidCents: 1299,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            ownedItem: testOwnedItem(
              id: 'owned-1',
              itemId: 'movie-1',
              purchaseDate: DateTime.utc(2026, 5, 11),
              pricePaidCents: 1299,
              coverPriceCents: 1599,
              soldAt: DateTime.utc(2026, 5, 20),
              sellPriceCents: 1899,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
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
      'personal section labels digital ownership and hides physical-only facts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorPersonalSection(
            entry: LibraryWorkspaceEntry(
              id: 'movie-1',
              mediaType: 'movie',
              title: 'Blade Runner 2049',
              variant: 'Digital',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            ownedItem: testOwnedItem(
              id: 'owned-1',
              itemId: 'movie-1',
              isDigital: true,
              pricePaidCents: 1299,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            accent: Colors.orange,
          ),
        ),
      ),
    );

    expect(find.text('Ownership'), findsOneWidget);
    expect(find.text('Digital copy'), findsOneWidget);
    expect(find.text('Condition'), findsNothing);
    expect(find.text('Grade'), findsNothing);
    expect(find.text('Storage'), findsNothing);
  });

  testWidgets('inspector action bar avoids overflow on narrow widths', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 356,
            child: InspectorActionBar(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Fellowship of the Ring',
                isOwned: true,
                isWishlisted: true,
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              onToggleOwned: () {},
              onToggleWishlist: () {},
              onEdit: () {},
              onOpenDetails: () {},
              onCorrectMetadata: () {},
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
    expect(find.text('Owned'), findsOneWidget);
    expect(find.text('Wish list'), findsOneWidget);
  });

  testWidgets('book inspector hides the item images section', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Two Towers',
                ownedItemId: 'owned-1',
                creators: const [
                  {'name': 'J.R.R. Tolkien', 'role': 'Author'},
                ],
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              accent: Colors.orange,
              onAddOwned: () {},
              onRemoveOwned: () {},
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
            ownedItemId: 'owned-1',
            imageType: const Value('front_cover'),
            imageData: base64Decode(base64Encode(const [0, 1, 2, 3])),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );
    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'back-1',
            ownedItemId: 'owned-1',
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
              ownedItemId: 'owned-1',
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
    final type = collectarrLibraryTypes.byKind('book')!;
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'book-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 23, 10),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-2',
            itemId: 'book-1',
            condition: const Value('Very Fine'),
            updatedAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Return of the King',
                ownedItemId: 'owned-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              ),
              accent: Colors.orange,
              onAddOwned: () {},
              onRemoveOwned: () {},
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
    final type = collectarrLibraryTypes.byKind('book')!;
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'book-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 23, 10),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-2',
            itemId: 'book-1',
            condition: const Value('Very Fine'),
            updatedAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );
    OwnedItem? editedOwnedItem;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Return of the King',
                ownedItemId: 'owned-1',
                isOwned: true,
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              ),
              accent: Colors.orange,
              onAddOwned: () {},
              onRemoveOwned: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (ownedItem) => editedOwnedItem = ownedItem,
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Very Fine').last);
    await pumpUntilSettled(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(InspectorActionBar),
        matching: find.widgetWithText(OutlinedButton, 'Edit'),
      ).first,
    );
    await tester.pump();

    expect(editedOwnedItem?.id, 'owned-2');
  });

  testWidgets(
      'inspector hero switches local back-cover affordance with the selected copy',
      (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('book')!;

    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'book-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 23, 10),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-2',
            itemId: 'book-1',
            condition: const Value('Very Fine'),
            updatedAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );
    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'back-owned-2',
            ownedItemId: 'owned-2',
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
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Return of the King',
                ownedItemId: 'owned-1',
                isOwned: true,
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: testOwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                condition: 'Near Mint',
                updatedAt: DateTime.utc(2026, 5, 23, 10),
              ),
              accent: Colors.orange,
              onAddOwned: () {},
              onRemoveOwned: () {},
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

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Very Fine').last);
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
            entry: LibraryWorkspaceEntry(
              id: 'music-3',
              mediaType: 'music',
              title: 'The Black Parade',
              updatedAt: DateTime.utc(2026, 5, 23),
            ),
            detailsLayout: LibraryDetailsLayout.right,
            onEdit: () {},
            onShare: () {},
            onDuplicate: () {},
            onToggleOwned: () {},
            onLoan: () {},
            onRefreshMetadata: () {},
            onDetailsLayoutChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(LibraryDetailsLayoutDropdown), findsOneWidget);
  });
}
