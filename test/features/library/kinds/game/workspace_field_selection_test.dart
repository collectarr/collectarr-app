import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/catalog_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/schema/projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Games field choosers expose the missing dates and copy details', () {
    final fields = gameLibraryEntryWorkspaceSchema.toRegistry();
    final columns = fields.columns.map((column) => column.id.value).toSet();
    final sorts = fields.sorts.map((sort) => sort.id.value).toSet();
    const added = {
      'game.core_id',
      'game.description',
      'game.country',
      'game.language',
      'game.release_month',
      'game.purchase_month',
      'game.added_month',
      'game.modified_month',
      'game.modified_year',
      'game.completed_month',
      'game.storage_slot',
    };
    expect(columns, containsAll(added));
    expect(sorts, containsAll(added));
    expect(columns, contains('game.back_cover'));
    expect(
        sorts,
        containsAll({
          'game.genre',
          'game.audience_rating',
          'game.release_year',
          'game.condition',
          'game.location',
          'game.completed',
          'game.value_locked',
          'game.tags',
          'game.loaned_to',
          'game.loan_date',
          'game.due_date',
        }));
    for (final schema in [
      gameCatalogItemWorkspaceSchema,
      gameLibraryEntryWorkspaceSchema
    ]) {
      final registry = schema.toRegistry();
      for (final column
          in registry.columns.where((column) => column.sortable)) {
        expect(registry.sorts.map((sort) => sort.id.value),
            contains(column.sortId?.value ?? column.id.value),
            reason:
                'The column header must resolve a real sort: ${column.id.value}');
      }
    }
  });

  test('Games, Hardware and Toys keep their own sort and column fields', () {
    for (final kind in [
      CatalogMediaKind.game,
      CatalogMediaKind.gameHardware,
      CatalogMediaKind.gameToy
    ]) {
      final fields = libraryKindWorkspaceForKind(kind).workspaceFields;
      final ids = [
        ...fields.columns.map((column) => column.id.value),
        ...fields.sorts.map((sort) => sort.id.value),
      ];
      final namespace = switch (kind) {
        CatalogMediaKind.game => 'game.',
        CatalogMediaKind.gameHardware => 'game_hardware.',
        _ => 'game_toy.',
      };
      expect(ids.every((id) => id.startsWith(namespace)), isTrue,
          reason: kind.name);
      final labels =
          fields.columns.map((column) => column.metadata.label).toSet();
      expect(labels, containsAll({'Core ID', 'Description'}));
      if (kind != CatalogMediaKind.gameHardware) {
        expect(labels, isNot(contains('Hardware Type')));
        expect(labels, isNot(contains('Serial No.')));
      }
      if (kind != CatalogMediaKind.gameToy) {
        expect(labels, isNot(contains('Subtype')));
        expect(labels, isNot(contains('Type')));
      }
      if (kind != CatalogMediaKind.game) {
        expect(labels, isNot(contains('Developer')));
        expect(labels, isNot(contains('Completed')));
      }
    }
  });

  test('new Game sorts compare actual months, numbers, flags and tags', () {
    final early = _context(
      month: 2,
      year: 2020,
      personal: const GamePersonalData(
        tags: ['Zelda', 'Action'],
        purchaseDateParts: PartialDate(year: 2025, month: 2),
        details: GameEntryDetails(completed: false, valueIsLocked: false),
      ),
    );
    final late = _context(
      month: 10,
      year: 2026,
      personal: const GamePersonalData(
        tags: ['Puzzle'],
        purchaseDateParts: PartialDate(year: 2025, month: 10),
        details: GameEntryDetails(completed: true, valueIsLocked: true),
      ),
    );
    final registry = gameLibraryEntryWorkspaceSchema.toRegistry();
    for (final id in [
      'game.release_month',
      'game.release_year',
      'game.purchase_month',
      'game.completed',
      'game.value_locked',
      'game.tags'
    ]) {
      final sort = registry.sorts.singleWhere((sort) => sort.id.value == id);
      expect(sort.compare(early, late), lessThan(0), reason: id);
      expect(sort.compare(late, early), greaterThan(0), reason: id);
    }
    final noMonth = _context(month: null);
    final monthSort = registry.sorts
        .singleWhere((sort) => sort.id.value == 'game.release_month');
    expect(monthSort.compare(early, noMonth), lessThan(0));
    expect(monthSort.compare(noMonth, early), greaterThan(0));
    expect(monthSort.compare(noMonth, noMonth), 0);
  });

  test('Description column reads text without changing the saved rich text',
      () {
    const source = '<p><strong>Alpha</strong> &amp; Beta</p>';
    final context = _context(description: source);
    expect(GameCatalogWorkspaceFields.description.getValue(context),
        'Alpha & Beta');
    expect(context.dto.metadata.description, source);
  });

  test('Core ID is the catalog link, never the local copy ID', () {
    final unlinked = _context();
    final linked = _context(coreId: 'core-release-17');
    expect(GameCatalogWorkspaceFields.coreId.getValue(unlinked), isNull);
    expect(
        GameCatalogWorkspaceFields.coreId.getValue(linked), 'core-release-17');
    final catalog = LibraryProjectionContext(
      item: WorkspaceItem(
          target: const CatalogTargetRef(CatalogItemRef(
              kind: CatalogMediaKind.game, id: 'catalog-preview-19'))),
      personal: const PersonalOverlay(),
      dto: linked.dto,
    );
    expect(GameCatalogWorkspaceFields.coreId.getValue(catalog),
        'catalog-preview-19');
  });
}

LibraryProjectionContext<GameWorkspaceDto> _context({
  int? month = 2,
  int year = 2026,
  String? coreId,
  String? description,
  GamePersonalData personal = const GamePersonalData(),
}) {
  final metadata = GameCatalogMetadata(
    title: 'Test Game',
    description: description,
    releaseDateParts: PartialDate(year: year, month: month),
  );
  final entry = GameLibraryEntry(
    id: const LibraryEntryId('local-copy'),
    metadata: metadata,
    personal: personal,
    sourceCatalogRef: coreId == null
        ? null
        : CatalogItemRef(kind: CatalogMediaKind.game, id: coreId),
    updatedAt: DateTime.utc(2026),
  );
  return LibraryProjectionContext(
    item: WorkspaceItem(
      target: const EntryTargetRef(LibraryEntryRef(
          kind: CatalogMediaKind.game, id: LibraryEntryId('local-copy'))),
      libraryEntryDispatch: OpaqueLibraryEntryDispatch(
        ref: const LibraryEntryRef(
            kind: CatalogMediaKind.game, id: LibraryEntryId('local-copy')),
        kind: CatalogMediaKind.game,
        value: entry,
      ),
    ),
    personal: const PersonalOverlay(),
    dto: GameWorkspaceDto(
      common: const WorkspaceCommonProjection(title: 'Test Game'),
      personal: PersonalEntryProjection(),
      metadata: metadata,
    ),
  );
}
