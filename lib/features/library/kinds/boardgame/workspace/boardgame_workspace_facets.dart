import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final boardgameLibraryFacetDefinitions =
    <LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>>[
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.publisher,
    label: 'Publisher',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.publishers,
      dto.metadata?.publisher,
      ...dto.boardgame.publishers,
      dto.boardgame.publisher,
      dto.publisher,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.designer,
    label: 'Designer',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.designers,
      ...dto.boardgame.designers,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.mechanic,
    label: 'Mechanic',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.mechanics,
      ...dto.boardgame.mechanics,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.category,
    label: 'Category',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.categories,
      ...dto.boardgame.categories,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.family,
    label: 'Family',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.families,
      ...dto.boardgame.families,
    ]),
  ),
  LibraryFacetDefinition<BoardGameKind, BoardGameWorkspaceDto, String>(
    id: BoardGameFacetIds.theme,
    label: 'Theme',
    extractValues: (dto) => _boardGameFacetValues([
      ...?dto.metadata?.themes,
      ...dto.boardgame.themes,
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
