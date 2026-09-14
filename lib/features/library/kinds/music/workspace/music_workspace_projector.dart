import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
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
    final catalog = _catalogFor(source);
    return MusicWorkspaceDto(
      common: _musicCommonProjection(
        source,
        node,
        catalog.music,
        catalog.release,
      ),
      personal: PersonalCopyProjection.fromShelf(source),
      music: catalog.music,
      release: catalog.release,
    );
  }

  @override
  MusicWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final catalog = _catalogFor(source);
    final release = catalog.releaseForSummary(node.release);
    return MusicWorkspaceDto(
      common: _musicCommonProjection(source, node, catalog.music, release),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      music: catalog.music,
      release: release,
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

MusicWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final MusicWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected MusicWorkspaceCatalogData for music workspace');
}

WorkspaceCommonProjection _musicCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
  MusicReleaseGroup music,
  MusicRelease release,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: music.title,
    overrideSynopsis: music.synopsis,
    overrideReleaseDate: release.releaseDate ?? music.releaseDate,
    overrideCoverImageUrl: release.coverImageUrl ?? music.coverImageUrl,
  );
}
