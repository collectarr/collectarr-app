import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceProjector
    implements LibraryWorkspaceProjector<BoardGameWorkspaceDto> {
  const BoardGameWorkspaceProjector();

  @override
  BoardGameWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    final boardgame =
        BoardGameCatalogMapper.mapMetadataItemToBoardGame(source.catalogItem!);
    BoardGameMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is BoardGameMetadata) {
      metadata = km;
    }
    return BoardGameWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      boardgame: boardgame,
      metadata: metadata,
    );
  }

  @override
  BoardGameWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final boardgame =
        BoardGameCatalogMapper.mapMetadataItemToBoardGame(source.catalogItem!);
    final metadata = _metadataFor(source);
    return BoardGameWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      boardgame: boardgame,
      metadata: metadata,
    );
  }

  @override
  BoardGameWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }

  static BoardGameMetadata? _metadataFor(ShelfEntry source) {
    final metadata = source.catalogItem?.kindMetadata;
    if (metadata is BoardGameMetadata) {
      return metadata;
    }
    return metadata == null
        ? null
        : BoardGameMetadata.fromJson(source.catalogItem!.payload);
  }
}
