import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

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

final boardgameSmartListFacetFields =
    <LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, Object?>>[
  LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto,
      Iterable<String>>(
    metadata: BoardGameWorkspaceFieldMetadata.category,
    id: const LibraryFieldId<BoardGameKind, Iterable<String>>(
        'boardgame.category'),
    getValue: (context) =>
        _boardGameFacetValues(context.dto.metadata.categories),
  ),
  LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto,
      Iterable<String>>(
    metadata: BoardGameWorkspaceFieldMetadata.family,
    id: const LibraryFieldId<BoardGameKind, Iterable<String>>(
        'boardgame.family'),
    getValue: (context) => _boardGameFacetValues(context.dto.metadata.families),
  ),
  LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto,
      Iterable<String>>(
    metadata: BoardGameWorkspaceFieldMetadata.mechanic,
    id: const LibraryFieldId<BoardGameKind, Iterable<String>>(
        'boardgame.mechanic'),
    getValue: (context) =>
        _boardGameFacetValues(context.dto.metadata.mechanics),
  ),
  LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto,
      Iterable<String>>(
    metadata: BoardGameWorkspaceFieldMetadata.theme,
    id: const LibraryFieldId<BoardGameKind, Iterable<String>>(
        'boardgame.theme'),
    getValue: (context) => _boardGameFacetValues(context.dto.metadata.themes),
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
