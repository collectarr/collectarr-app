import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MusicWorkspaceDto> {
  const MusicWorkspaceProjector();

  @override
  MusicWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    final catalog = _catalogFor(source);
    final release = entity is LibraryReleaseRef
        ? catalog.releaseForSummary(entity.release)
        : catalog.release;
    return MusicWorkspaceDto(
      common: _musicCommonProjection(
        source,
        entity,
        catalog.music,
        release,
        overrideTitle: entity is LibraryReleaseRef ? release.title : null,
      ),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      music: catalog.music,
      release: release,
      groupListeningSummary: catalog.listeningSummary,
    );
  }
}

MusicWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final MusicWorkspaceCatalogData catalog) return catalog;

  // A collection row can outlive its catalog snapshot (for example after a
  // release-group migration or when an imported release no longer exists).
  // Keep the workspace typed and render the structural row instead of
  // crashing the whole Music page. This deliberately creates no generic or
  // legacy catalog object; it is only a typed, metadata-free placeholder.
  final sourceRef = source.catalogRef;
  final rootId = (sourceRef?.kind == CatalogMediaKind.music
          ? sourceRef!.rootScope.id
          : source.itemId)
      .trim();
  final rootRef = CatalogEntityRef(
    kind: CatalogMediaKind.music,
    entityType: CatalogEntityTypeId.root,
    id: rootId.isEmpty ? 'unknown-music-item' : rootId,
  );
  final music = MusicReleaseGroup(
    id: MusicReleaseGroupId(rootRef.id),
    title: source.title,
    coverImageUrl: source.catalogSummary?.imageUrl,
  );
  return MusicWorkspaceCatalogData.fromMusic(music, ref: rootRef);
}

WorkspaceCommonProjection _musicCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  MusicReleaseGroup music,
  MusicRelease release, {
  String? overrideTitle,
}) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: overrideTitle ?? music.title,
    overrideSynopsis: music.synopsis,
    overrideReleaseDate: release.releaseDate ?? music.releaseDate,
    overrideCoverImageUrl: release.coverImageUrl ?? music.coverImageUrl,
  );
}
