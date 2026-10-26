import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import '../data/game_hardware_library_entry_projection.dart';
import 'data.dart';
import 'dto.dart';

final class GameHardwareWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<GameHardwareWorkspaceDto> {
  const GameHardwareWorkspaceProjector();
  @override
  GameHardwareWorkspaceDto project(
      {required WorkspaceItem item, required PersonalOverlay personal}) {
    final data = item.kindPresentationData;
    if (data is! GameHardwareWorkspaceData) {
      throw StateError('Expected GameHardware workspace data');
    }
    final metadata = data.metadata;
    return GameHardwareWorkspaceDto(
        common: WorkspaceCommonProjection.fromKindPresentation(item,
            title: metadata.title,
            synopsis: metadata.description,
            releaseDate: metadata.releaseDate,
            coverImageUrl: metadata.coverImageUrl),
        personal: PersonalEntryProjection.fromShelf(item, personal),
        metadata: metadata,
        entry: GameHardwareLibraryEntryProjection.fromDispatch(
            item.libraryEntryDispatch));
  }
}
