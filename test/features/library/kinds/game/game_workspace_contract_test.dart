import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_facet_definitions.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Game workspace exposes a complete typed schema registry', () {
    final registry = gameKindModule.fields;
    final fieldIds = registry.fields.map((field) => field.id.value).toList();
    final columnIds =
        registry.columns.map((column) => column.id.value).toList();
    final sortIds = registry.sorts.map((sort) => sort.id.value).toList();
    final groupIds = registry.groups.map((group) => group.id.value).toList();

    expect(registry.kindNamespace, 'game');
    expect(fieldIds, isNotEmpty);
    expect(columnIds, isNotEmpty);
    expect(sortIds, isNotEmpty);
    expect(groupIds, isNotEmpty);
    expect(fieldIds.toSet(), hasLength(fieldIds.length));
    expect(columnIds.toSet(), hasLength(columnIds.length));
    expect(sortIds.toSet(), hasLength(sortIds.length));
    expect(groupIds.toSet(), hasLength(groupIds.length));
    expect(fieldIds.every((id) => id.startsWith('game.')), isTrue);
    expect(columnIds.every((id) => id.startsWith('game.')), isTrue);
    expect(sortIds.every((id) => id.startsWith('game.')), isTrue);
    expect(groupIds.every((id) => id.startsWith('game.')), isTrue);

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
      gameKindModule.facets!.definitions.map((definition) => definition.id.value),
      [
        GameFacetIds.platform.value,
        GameFacetIds.publisher.value,
        GameFacetIds.developer.value,
        GameFacetIds.franchise.value,
        GameFacetIds.genre.value,
        GameFacetIds.region.value,
      ],
    );
  });

  test('Game facets extract typed metadata and remain kind-owned', () {
    final dto = GameWorkspaceDto(
      common: const WorkspaceCommonProjection(
        title: 'Super Mario 64',
        publisher: 'Nintendo',
        country: 'US',
      ),
      personal: PersonalCopyProjection(),
      game: const GameCatalogItem(
        id: 'game-1',
        work: GameWorkMetadata(
          title: 'Super Mario 64',
          platforms: ['Nintendo 64'],
          genres: ['Platformer'],
        ),
        releases: [],
      ),
      metadata: const GameCatalogMetadata(
        title: 'Super Mario 64',
        platform: 'Nintendo 64',
        platforms: ['Nintendo 64', 'Virtual Console'],
        releaseRegion: 'NTSC-U',
        developers: ['Nintendo EAD'],
        publishers: ['Nintendo'],
        franchise: 'Super Mario',
        genres: ['Platformer'],
      ),
    );

    final values = <String, List<String>>{
      for (final definition in gameLibraryFacetDefinitions)
        definition.id.value: definition.extractValues(dto).toList(),
    };
    expect(values[GameFacetIds.platform.value], [
      'Nintendo 64',
      'Virtual Console',
    ]);
    expect(values[GameFacetIds.publisher.value], ['Nintendo']);
    expect(values[GameFacetIds.developer.value], ['Nintendo EAD']);
    expect(values[GameFacetIds.franchise.value], ['Super Mario']);
    expect(values[GameFacetIds.genre.value], ['Platformer']);
    expect(values[GameFacetIds.region.value], ['NTSC-U', 'US']);

    final facets = gameKindModule.facets!;
    expect(
      facets.externalFacetBucketIdsByMode.keys,
      containsAll(['game.genre', 'game.region']),
    );
    final vocabularyCapability = gameKindModule.edit.vocabularies;
    expect(vocabularyCapability, isNotNull);
    expect(
      vocabularyCapability!.definitions.map((definition) => definition.key),
      GameVocabularies.all.map((definition) => definition.key),
    );
    expect(
      vocabularyCapability.definitions
          .map((definition) => definition.key)
          .every((key) => key.startsWith('game.')),
      isTrue,
    );
  });
}