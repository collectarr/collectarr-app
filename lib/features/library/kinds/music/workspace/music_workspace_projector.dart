import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicCatalogItemWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MusicWorkspaceProjection> {
  const MusicCatalogItemWorkspaceProjector();

  @override
  MusicCatalogItemWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, LibraryEntityScope.catalogItem);
    final catalog = _catalogFor(source);
    return MusicCatalogItemWorkspaceDto(
      common: _musicCommonProjection(source, entity, catalog),
      personal: PersonalCopyProjection.fromShelf(
        source,
      ),
      music: catalog.music,
      listeningSummary: catalog.listeningSummary,
    );
  }
}

final class MusicLibraryEntryWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MusicWorkspaceProjection> {
  const MusicLibraryEntryWorkspaceProjector();

  @override
  MusicLibraryEntryWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, LibraryEntityScope.libraryEntry);
    final catalog = _catalogFor(source);
    return MusicLibraryEntryWorkspaceDto(
      common: _musicCommonProjection(source, entity, catalog),
      personal: PersonalCopyProjection.fromShelf(
        source,
      ),
      music: catalog.music,
      listeningSummary: catalog.listeningSummary,
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
  LibraryEntityRef node,
  MusicWorkspaceCatalogData catalog,
) =>
    WorkspaceCommonProjection.fromStructuralShelf(
      source,
      node,
      overrideTitle: catalog.music.title,
      overrideReleaseDate: catalog.music.releaseDate,
      overrideCoverImageUrl: catalog.music.coverImageUrl,
    );
