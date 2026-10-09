import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final boardgameLibraryFacetDefinitions =
    <LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>>[
  if (BoardGameFieldIdentities.publisher.filterable)
    LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
      metadata: BoardGameFieldIdentities.publisher,
      extractValues: (dto) => _boardGameFacetValues([
        ...dto.metadata.publishers,
        dto.metadata.publisher,
        dto.publisher,
      ]),
    ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    metadata: BoardGameWorkspaceFieldMetadata.designer,
    extractValues: (dto) => _boardGameFacetValues([
      ...dto.metadata.designers,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    metadata: BoardGameWorkspaceFieldMetadata.mechanic,
    extractValues: (dto) => _boardGameFacetValues([
      ...dto.metadata.mechanics,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    metadata: BoardGameWorkspaceFieldMetadata.category,
    extractValues: (dto) => _boardGameFacetValues([
      ...dto.metadata.categories,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    metadata: BoardGameWorkspaceFieldMetadata.family,
    extractValues: (dto) => _boardGameFacetValues([
      ...dto.metadata.families,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    metadata: BoardGameWorkspaceFieldMetadata.theme,
    extractValues: (dto) => _boardGameFacetValues([
      ...dto.metadata.themes,
    ]),
  ),
];

Iterable<String> _boardGameFacetValues(Iterable<String?> values) sync* {
  final seen = <String>{};
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty || !seen.add(normalized)) {
      continue;
    }
    yield normalized;
  }
}
