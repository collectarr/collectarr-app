import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GameWorkspaceProjector
    implements LibraryWorkspaceProjector<GameWorkspaceDto> {
  const GameWorkspaceProjector();

  @override
  GameWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    final game = GameCatalogMapper.mapMetadataItemToGame(source.catalogItem!);
    GameCatalogMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is GameCatalogMetadata) {
      metadata = km;
    } else if (km != null) {
      metadata = GameCatalogMetadata.fromJson(km.toSyncPayload());
    }
    return GameWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      game: game,
      metadata: metadata,
    );
  }

  @override
  GameWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final game = GameCatalogMapper.mapMetadataItemToGame(source.catalogItem!);
    GameCatalogMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is GameCatalogMetadata) {
      metadata = km;
    } else if (km != null) {
      metadata = GameCatalogMetadata.fromJson(km.toSyncPayload());
    }
    return GameWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      game: game,
      metadata: metadata,
    );
  }

  @override
  GameWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}
