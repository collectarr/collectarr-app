import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<TvWorkspaceDto> {
  const TvWorkspaceProjector();

  @override
  TvWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog.video, entity);
    return TvWorkspaceDto(
      common: _tvCommonProjection(source, entity, catalog.video, release),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      video: catalog.video,
      series: catalog.series,
      release: release,
      metadata: catalog.metadata,
    );
  }
}

TvCatalogRelease? _releaseForEntity(
  TvCatalogItem video,
  LibraryEntityRef entity,
) {
  final releaseId = switch (entity) {
    LibraryWorkRef() => null,
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
  };
  if (releaseId == null) return null;
  for (final release in video.releases) {
    if (release.id == releaseId) return release;
  }
  throw StateError(
    'TV release "$releaseId" is not present in the canonical work graph',
  );
}

TvWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final TvWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected TvWorkspaceCatalogData for TV workspace');
}

WorkspaceCommonProjection _tvCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  TvCatalogItem video,
  TvCatalogRelease? release,
) {
  final isWork = node is LibraryWorkRef;
  final title = isWork ? video.work.title : release!.title;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: title,
    overrideSynopsis: isWork ? video.work.synopsis : null,
    overrideReleaseDate:
        release?.releaseDate ?? (isWork ? video.work.releaseDate : null),
    overrideCoverImageUrl: release?.frontCoverUrl,
  );
}
