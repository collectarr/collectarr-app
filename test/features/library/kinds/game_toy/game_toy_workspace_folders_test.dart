import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/widgets.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/contribution.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('folders keep individual tags and group timestamps by calendar day', () {
    final metadata = GameToyCatalogMetadata(title: 'Fictional inventory');
    final entry = GameToyLibraryEntry(
      id: const LibraryEntryId('folder-test'),
      metadata: metadata,
      personal: const GameToyPersonalData(tags: ['A, B', 'Gift']),
      createdAt: DateTime.utc(2026, 10, 16, 9, 23),
      updatedAt: DateTime.utc(2026, 10, 18, 17, 42),
    );
    const personal = PersonalOverlay();
    final context = LibraryProjectionContext(
      item: const WorkspaceItem(
          target: CatalogTargetRef(CatalogItemRef(
              kind: CatalogMediaKind.gameToy, id: 'folder-test'))),
      personal: personal,
      dto: GameToyWorkspaceDto(
        common: const WorkspaceCommonProjection(title: 'Fictional inventory'),
        personal: PersonalEntryProjection(),
        metadata: metadata,
        entry: entry,
      ),
    );
    final groups =
        gameToyKindWorkspace.libraryEntryWorkspace.typedFields.groups;
    Object? value(String key) => groups
        .singleWhere((group) => group.id.value == 'game_toy.$key')
        .getValue(context);
    expect(value('tags'), ['A, B', 'Gift']);
    expect(value('added_date'), '2026-10-16');
    expect(value('modified_date'), '2026-10-18');
    expect(
        groups
            .singleWhere((group) => group.id.value == 'game_toy.completeness')
            .category,
        'Value');
  });
  test(
      'partial date folders never invent unknown months and include reference groups',
      () {
    final registry = gameToyKindWorkspace.libraryEntryWorkspace.typedFields;
    final catalog = gameToyKindWorkspace.catalogItemWorkspace.typedFields;
    Object? value(String key, {PartialDate? release, PartialDate? purchase}) {
      final context = _folderContext(release: release, purchase: purchase);
      return registry.groups
          .singleWhere((g) => g.id.value == 'game_toy.$key')
          .getValue(context);
    }

    expect(value('release_year', release: const PartialDate(year: 2020)), 2020);
    expect(
        value('release_month', release: const PartialDate(year: 2020)), isNull);
    expect(
        value('release_month',
            release: const PartialDate(year: 2020, month: 9)),
        '09 - September');
    expect(
        value('purchase_year', purchase: const PartialDate(year: 2022)), 2022);
    expect(value('purchase_month', purchase: const PartialDate(year: 2022)),
        isNull);
    expect(
        value('purchase_month',
            purchase: const PartialDate(year: 2022, month: 4)),
        '04 - April');
    final ids = registry.groups.map((g) => g.id.value).toSet();
    expect(
        ids,
        containsAll([
          'game_toy.has_front',
          'game_toy.has_box',
          'game_toy.image_type',
          'game_toy.added_month',
          'game_toy.added_year',
          'game_toy.modified_month',
          'game_toy.collection_status',
          'game_toy.location',
          'game_toy.rating'
        ]));
    expect(ids.any((id) => id.contains('completed') || id.contains('storage')),
        isFalse);
    expect(catalog.groups.any((g) => g.id.value == 'game_toy.purchase_year'),
        isFalse);
  });
  test(
      'image, status and location folders read personal overlays without leaking into Core',
      () {
    final registry = gameToyKindWorkspace.libraryEntryWorkspace.typedFields;
    Object? value(String key,
            {String? cover,
            PersonalOverlay overlay = const PersonalOverlay()}) =>
        registry.groups
            .singleWhere((g) => g.id.value == 'game_toy.$key')
            .getValue(_folderContext(cover: cover, overlay: overlay));
    expect(value('has_front'), 'No');
    expect(value('has_box'), 'No');
    expect(value('has_front', cover: 'https://example.invalid/fixture.jpg'),
        'Yes');
    const overlay = PersonalOverlay(
        imageTypes: {'personal:back_cover', 'custom_art'},
        locationPath: 'Room / Shelf');
    expect(value('has_box', overlay: overlay), 'Yes');
    expect(value('image_type', overlay: overlay),
        containsAll(['Box Image', 'custom_art']));
    expect(value('collection_status'), 'On Wish List');
    expect(value('location', overlay: overlay), 'Room / Shelf');
    expect(value('rating'), 8);
    expect(value('release_year'), isNull);
  });
  test(
      'workspace columns keep personal fields local and money sorts numerically',
      () {
    final registry = gameToyKindWorkspace.libraryEntryWorkspace.typedFields;
    final catalog = gameToyKindWorkspace.catalogItemWorkspace.typedFields;
    final ids = registry.columns.map((column) => column.id.value).toSet();
    expect(
        ids,
        containsAll([
          'game_toy.purchase_price',
          'game_toy.rating',
          'game_toy.location',
          'game_toy.collection_status',
          'game_toy.release_month',
          'game_toy.release_year',
          'game_toy.purchase_month',
          'game_toy.purchase_year',
          'game_toy.added_datetime',
          'game_toy.modified_datetime'
        ]));
    expect(
        catalog.columns
            .any((column) => column.id.value == 'game_toy.purchase_price'),
        isFalse);
    final price = registry.sorts
        .singleWhere((sort) => sort.id.value == 'game_toy.purchase_price');
    expect(
        price.compare(_folderContext(purchasePrice: 100),
            _folderContext(purchasePrice: 90000)),
        lessThan(0));
    expect(price.compare(_folderContext(), _folderContext(purchasePrice: 100)),
        greaterThan(0));
    expect(
        registry.columns
            .singleWhere(
                (column) => column.id.value == 'game_toy.purchase_price')
            .group,
        'Value');
    final titleSort =
        registry.sorts.singleWhere((sort) => sort.id.value == 'game_toy.title');
    expect(
        titleSort.compare(_folderContext(title: 'The Z', sortKey: 'Z'),
            _folderContext(title: 'Y')),
        greaterThan(0));
    expect(
        titleSort.compare(
            _folderContext(
                title: 'The Z',
                sortKey: 'Z',
                sorting: const LibrarySortingOptions(useSortTitles: false)),
            _folderContext(
                title: 'Y',
                sorting: const LibrarySortingOptions(useSortTitles: false))),
        lessThan(0));
  });
  test('image columns use distinct front and box sources and presence flags',
      () {
    final registry = gameToyKindWorkspace.libraryEntryWorkspace.typedFields;
    final context = _folderContext(
        cover: 'https://example.invalid/front.jpg',
        overlay: const PersonalOverlay(imageTypes: {'personal:back_cover'}));
    final front = registry.columns
        .singleWhere((column) => column.id.value == 'game_toy.front_image')
        .cellValue!(context) as SizedBox;
    final box = registry.columns
        .singleWhere((column) => column.id.value == 'game_toy.box_image')
        .cellValue!(context) as SizedBox;
    expect((front.child! as LibraryCoverImage).imageUrl,
        'https://example.invalid/front.jpg');
    expect((box.child! as LibraryCoverImage).imageUrl, isNull);
    expect((box.child! as LibraryCoverImage).localImageType, 'back_cover');
    expect((box.child! as LibraryCoverImage).libraryEntryRef!.kind,
        CatalogMediaKind.gameToy);
    expect(
        registry.columns
            .singleWhere((column) => column.id.value == 'game_toy.has_box')
            .getValue(context),
        'Yes');
    expect(
        registry.columns
            .singleWhere((column) => column.id.value == 'game_toy.has_front')
            .getValue(context),
        'Yes');
  });
  testWidgets('money columns display decimal amounts instead of integer cents',
      (tester) async {
    final registry = gameToyKindWorkspace.libraryEntryWorkspace.typedFields;
    final context = _folderContext(purchasePrice: 1234, valueCents: 1758);
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Column(children: [
          registry.columns
              .singleWhere(
                  (column) => column.id.value == 'game_toy.purchase_price')
              .cellValue!(context),
          registry.columns
              .singleWhere((column) => column.id.value == 'game_toy.value')
              .cellValue!(context),
        ])));
    expect(find.textContaining('12.34'), findsOneWidget);
    expect(find.textContaining('17.58'), findsOneWidget);
  });
}

LibraryProjectionContext<GameToyWorkspaceDto> _folderContext(
    {PartialDate? release,
    PartialDate? purchase,
    int? purchasePrice,
    int? valueCents,
    String title = 'Fictional inventory',
    String? sortKey,
    LibrarySortingOptions sorting = const LibrarySortingOptions(),
    String? cover,
    PersonalOverlay overlay = const PersonalOverlay()}) {
  final metadata = GameToyCatalogMetadata(
      title: title,
      sortKey: sortKey,
      releaseDateParts: release,
      coverImageUrl: cover);
  final entry = GameToyLibraryEntry(
      id: const LibraryEntryId('folders'),
      metadata: metadata,
      personal: GameToyPersonalData(
          purchaseDateParts: purchase,
          collectionStatus: 'Wish List',
          rating: 8,
          pricePaidCents: purchasePrice,
          marketValueCents: valueCents,
          currency: 'USD'),
      updatedAt: DateTime.utc(2026));
  return LibraryProjectionContext(
      item: const WorkspaceItem(
          target: CatalogTargetRef(
              CatalogItemRef(kind: CatalogMediaKind.gameToy, id: 'folders'))),
      personal: overlay,
      sorting: sorting,
      dto: GameToyWorkspaceDto(
          common: const WorkspaceCommonProjection(title: 'Fictional inventory'),
          personal: PersonalEntryProjection(),
          metadata: metadata,
          entry: entry));
}
