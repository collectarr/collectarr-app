import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final gameLibraryFacetDefinitions =
    <LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>>[
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    id: GameFacetIds.platform,
    label: 'Platform',
    extractValues: (dto) => _values([
      ...?dto.metadata?.platforms,
      dto.metadata?.platform,
      ...dto.game.platforms,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    id: GameFacetIds.publisher,
    label: 'Publisher',
    extractValues: (dto) => _values([
      ...?dto.metadata?.publishers,
      dto.metadata?.publishers.firstOrNull,
      dto.publisher,
      dto.game.publisher,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    id: GameFacetIds.developer,
    label: 'Developer',
    extractValues: (dto) => _values([
      ...?dto.metadata?.developers,
      dto.developer,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    id: GameFacetIds.franchise,
    label: 'Franchise',
    extractValues: (dto) => _values([dto.franchise]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    id: GameFacetIds.genre,
    label: 'Genre',
    extractValues: (dto) => _values([
      ...?dto.metadata?.genres,
      ...dto.game.genres,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    id: GameFacetIds.region,
    label: 'Region',
    extractValues: (dto) => _values([
      dto.region,
      dto.metadata?.country,
    ]),
  ),
];

Iterable<String> _values(Iterable<String?> values) sync* {
  final seen = <String>{};
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty || !seen.add(normalized)) {
      continue;
    }
    yield normalized;
  }
}
