import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<TvWorkspaceDto> {
  const TvWorkspaceProjector({this.expectedScope});

  final LibraryEntityScope? expectedScope;

  @override
  TvWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    return TvWorkspaceDto(
      common: _tvCommonProjection(source, entity, catalog.metadata),
      personal: PersonalCopyProjection.fromShelf(
        source,
      ),
      series: catalog.series,
      metadata: catalog.metadata,
    );
  }
}

TvWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final TvWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected TvWorkspaceCatalogData for TV workspace');
}

WorkspaceCommonProjection _tvCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  TvSeriesMetadata? metadata,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: metadata?.title,
    overrideSynopsis: metadata?.synopsis,
    overrideReleaseDate: metadata?.firstAirDate,
  );
}
