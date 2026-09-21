import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicReleaseGroupWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MusicWorkspaceProjection> {
  const MusicReleaseGroupWorkspaceProjector();

  @override
  MusicReleaseGroupWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, LibraryEntityScope.work);
    final catalog = _catalogFor(source);
    return MusicReleaseGroupWorkspaceDto(
      common: _musicCommonProjection(source, entity, catalog.music, null),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      music: catalog.music,
      release: null,
      groupListeningSummary: catalog.listeningSummary,
    );
  }
}

final class MusicReleaseWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MusicWorkspaceProjection> {
  const MusicReleaseWorkspaceProjector();

  @override
  MusicReleaseWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, LibraryEntityScope.release);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog, entity);
    return MusicReleaseWorkspaceDto(
      common: _musicCommonProjection(
        source,
        entity,
        catalog.music,
        release,
        overrideTitle: release.title,
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

final class MusicOwnedCopyWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MusicWorkspaceProjection> {
  const MusicOwnedCopyWorkspaceProjector();

  @override
  MusicOwnedCopyWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, LibraryEntityScope.copy);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog, entity);
    return MusicOwnedCopyWorkspaceDto(
      common: _musicCommonProjection(
        source,
        entity,
        catalog.music,
        release,
        overrideTitle: release.title,
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
  throw StateError('Expected MusicWorkspaceCatalogData for music workspace');
}

MusicRelease _releaseForEntity(
  MusicWorkspaceCatalogData catalog,
  LibraryEntityRef entity,
) {
  return switch (entity) {
    LibraryReleaseRef(:final releaseId) => _requireRelease(catalog, releaseId),
    LibraryCopyRef(:final releaseId) => _releaseForId(catalog, releaseId),
    _ => throw StateError(
        'Music release projection requires a concrete release or copy reference',
      ),
  };
}

MusicRelease _releaseForId(
    MusicWorkspaceCatalogData catalog, String releaseId) {
  final lookup = catalog.lookupRelease(releaseId);
  return switch (lookup) {
    MusicReleaseFound(:final release) => release,
    MusicReleaseMissing() => throw StateError(
        'Music release "$releaseId" is not present in the canonical release group graph',
      ),
    MusicReleaseNeedsFetch() => throw StateError(
        'Music release "$releaseId" must be fetched before it can be projected',
      ),
  };
}

MusicRelease _requireRelease(
  MusicWorkspaceCatalogData catalog,
  String? releaseId,
) {
  if (releaseId == null || releaseId.trim().isEmpty) {
    throw StateError('Music release projection requires a concrete release');
  }
  return _releaseForId(catalog, releaseId);
}

WorkspaceCommonProjection _musicCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  MusicReleaseGroup music,
  MusicRelease? release, {
  String? overrideTitle,
}) {
  final isWork = node is LibraryWorkRef;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: overrideTitle ?? (isWork ? music.title : release!.title),
    overrideSynopsis: isWork ? music.synopsis : null,
    overrideReleaseDate:
        release?.releaseDate ?? (isWork ? music.releaseDate : null),
    overrideCoverImageUrl:
        release?.coverImageUrl ?? (isWork ? music.coverImageUrl : null),
  );
}
