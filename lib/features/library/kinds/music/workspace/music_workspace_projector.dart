import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceProjector
    implements LibraryWorkspaceProjector<MusicWorkspaceDto> {
  const MusicWorkspaceProjector();

  @override
  MusicWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final music = MusicCatalogMapper.mapMetadataItemToMusic(
      source.catalogItem!.toTransportItem(),
    );
    final release = MusicWorkspaceMapper.fromCatalogItem(
      source.catalogItem!.toTransportItem(),
    );
    MusicCatalogMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is MusicCatalogMetadata) {
      metadata = km;
    }
    return MusicWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      music: music,
      release: release,
      metadata: metadata,
    );
  }

  @override
  MusicWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final music = MusicCatalogMapper.mapMetadataItemToMusic(
      source.catalogItem!.toTransportItem(),
    );
    final release = MusicWorkspaceMapper.fromCatalogItem(
      source.catalogItem!.toTransportItem(),
      releaseId: node.releaseId,
      edition: node.edition,
    );
    MusicCatalogMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is MusicCatalogMetadata) {
      metadata = km;
    }
    return MusicWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      music: music,
      release: release,
      metadata: metadata,
    );
  }

  @override
  MusicWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}
