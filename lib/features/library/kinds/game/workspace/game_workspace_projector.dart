import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

/// Projects a concrete Game Catalog Item and its App-collection item state.
final class GameWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<GameWorkspaceDto> {
  const GameWorkspaceProjector();

  @override
  GameWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    return GameWorkspaceDto(
      common: WorkspaceCommonProjection.fromKindPresentation(
        item,
        title: catalog.metadata.title,
        synopsis: catalog.metadata.synopsis,
        releaseDate: catalog.metadata.releaseDate,
        coverImageUrl: catalog.metadata.coverImageUrl,
      ),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      metadata: catalog.metadata,
      valuations: GameLibraryEntryProjection.fromDispatch(
        item.libraryEntryDispatch,
      )?.personal.details.valuations,
    );
  }
}

GameWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final GameWorkspaceData catalog) return catalog;
  throw StateError('Expected GameWorkspaceData for game workspace');
}
