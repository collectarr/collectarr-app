import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import '../data/game_toy_library_entry_projection.dart';
import 'game_toy_workspace_data.dart';
import 'game_toy_workspace_dto.dart';

final class GameToyWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<GameToyWorkspaceDto> {
  const GameToyWorkspaceProjector();
  @override
  GameToyWorkspaceDto project(
      {required WorkspaceItem item, required PersonalOverlay personal}) {
    final data = item.kindPresentationData;
    if (data is! GameToyWorkspaceData) {
      throw StateError('Expected GameToy workspace data');
    }
    final metadata = data.metadata;
    return GameToyWorkspaceDto(
        common: WorkspaceCommonProjection.fromKindPresentation(item,
            title: metadata.title,
            synopsis: metadata.description,
            releaseDate: metadata.releaseDate,
            coverImageUrl: metadata.coverImageUrl),
        personal: PersonalEntryProjection.fromShelf(item, personal),
        metadata: metadata,
        entry: GameToyLibraryEntryProjection.fromDispatch(
            item.libraryEntryDispatch));
  }
}
