import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MovieWorkspaceDto> {
  const MovieWorkspaceProjector({this.expectedScope});

  final LibraryEntityScope? expectedScope;

  @override
  MovieWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    return MovieWorkspaceDto(
      common: WorkspaceCommonProjection.fromStructuralShelf(
        source,
        entity,
        overrideTitle: catalog.metadata.title,
        overrideSynopsis: catalog.metadata.synopsis,
        overrideReleaseDate: catalog.releaseDate,
        overrideCoverImageUrl: catalog.metadata.coverImageUrl,
      ),
      personal: PersonalCopyProjection.fromShelf(
        source,
      ),
      metadata: catalog.metadata,
    );
  }
}

MovieWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final MovieWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected MovieWorkspaceCatalogData for movie workspace');
}
