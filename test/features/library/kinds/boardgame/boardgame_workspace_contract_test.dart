import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoardGame workspace exposes a complete typed schema registry', () {
    final registry = boardGameKindModule.fields;
    final fieldIds = registry.fields.map((field) => field.id.value).toList();
    final columnIds =
        registry.columns.map((column) => column.id.value).toList();
    final sortIds = registry.sorts.map((sort) => sort.id.value).toList();
    final groupIds = registry.groups.map((group) => group.id.value).toList();

    expect(registry.kindNamespace, 'boardgame');
    expect(fieldIds, isNotEmpty);
    expect(columnIds, isNotEmpty);
    expect(sortIds, isNotEmpty);
    expect(groupIds, isNotEmpty);
    expect(fieldIds.toSet(), hasLength(fieldIds.length));
    expect(columnIds.toSet(), hasLength(columnIds.length));
    expect(sortIds.toSet(), hasLength(sortIds.length));
    expect(groupIds.toSet(), hasLength(groupIds.length));
    expect(fieldIds.every((id) => id.startsWith('boardgame.')), isTrue);
    expect(columnIds.every((id) => id.startsWith('boardgame.')), isTrue);
    expect(sortIds.every((id) => id.startsWith('boardgame.')), isTrue);
    expect(groupIds.every((id) => id.startsWith('boardgame.')), isTrue);

    for (final column in registry.columns) {
      expect(fieldIds, contains(column.id.value));
    }
    for (final visibleColumn in registry.defaultVisibleColumns) {
      expect(registry.columnDefinitionForId(visibleColumn), isNotNull);
    }
    expect(registry.findSortDefinition(registry.defaultSort), isNotNull);
    final defaultGroup = registry.defaultGroup;
    expect(defaultGroup, isNotNull);
    expect(registry.findGroupDefinition(defaultGroup!), isNotNull);

    expect(
      boardGameKindModule.facets!.definitions
          .map((definition) => definition.id.value),
      [
        BoardGameFacetIds.publisher.value,
        BoardGameFacetIds.designer.value,
        BoardGameFacetIds.mechanic.value,
        BoardGameFacetIds.category.value,
        BoardGameFacetIds.family.value,
        BoardGameFacetIds.theme.value,
      ],
    );
  });

  test('BoardGame facets extract typed metadata and remain kind-owned', () {
    final dto = BoardGameWorkspaceDto(
      common: const WorkspaceCommonProjection(
        title: 'Catan',
        publisher: 'Kosmos',
      ),
      personal: PersonalCopyProjection(),
      boardgame: const BoardGameCatalogItem(
        id: 'boardgame-1',
        work: BoardGameWorkMetadata(
          title: 'Catan',
          publishers: ['Kosmos'],
          designers: ['Klaus Teuber'],
          mechanics: ['Trading'],
          categories: ['Negotiation'],
          families: ['Catan'],
          themes: ['Economic'],
        ),
        stats: BoardGameStatsMetadata(),
        releases: [],
      ),
      metadata: const BoardGameMetadata(
        title: 'Catan',
        publishers: ['Kosmos', 'Mayfair Games'],
        designers: ['Klaus Teuber'],
        mechanics: ['Trading', 'Network Building'],
        categories: ['Negotiation'],
        families: ['Catan'],
        themes: ['Economic', 'Political'],
      ),
    );

    final values = <String, List<String>>{
      for (final definition in boardgameLibraryFacetDefinitions)
        definition.id.value: definition.extractValues(dto).toList(),
    };
    expect(values[BoardGameFacetIds.publisher.value], [
      'Kosmos',
      'Mayfair Games',
    ]);
    expect(values[BoardGameFacetIds.designer.value], ['Klaus Teuber']);
    expect(values[BoardGameFacetIds.mechanic.value], [
      'Trading',
      'Network Building',
    ]);
    expect(values[BoardGameFacetIds.category.value], ['Negotiation']);
    expect(values[BoardGameFacetIds.family.value], ['Catan']);
    expect(values[BoardGameFacetIds.theme.value], ['Economic', 'Political']);
  });
}
