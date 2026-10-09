import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final gameLibraryFacetDefinitions =
    <LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>>[
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    metadata: GameWorkspaceFieldMetadata.platform,
    extractValues: (dto) => _values([
      ...dto.metadata.platforms,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    metadata: GameWorkspaceFieldMetadata.publisher,
    extractValues: (dto) => _values([
      dto.metadata.publisher,
      dto.publisher,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    metadata: GameWorkspaceFieldMetadata.developer,
    extractValues: (dto) => _values([
      ...dto.metadata.developers,
      dto.developer,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    metadata: GameFieldIdentities.franchise,
    extractValues: (dto) => _values([dto.franchise]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    metadata: GameWorkspaceFieldMetadata.genre,
    extractValues: (dto) => _values([
      ...dto.metadata.genres,
    ]),
  ),
  LibraryFacetDefinition<GameKind, GameWorkspaceDto, String>(
    metadata: GameWorkspaceFieldMetadata.region,
    extractValues: (dto) => _values([
      dto.region,
      dto.metadata.country,
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
