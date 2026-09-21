import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<ComicWorkspaceDto> {
  const ComicWorkspaceProjector({this.expectedScope});

  final LibraryEntityScope? expectedScope;

  @override
  ComicWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog.comic, entity);
    final ownedItem =
        ComicOwnedItemProjection.fromDispatch(source.ownedItemDispatch);
    return ComicWorkspaceDto(
      common: _comicCommonProjection(source, entity, catalog.comic, release),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      comic: catalog.comic,
      release: release,
      ownedItem: ownedItem,
    );
  }
}

ComicRelease? _releaseForEntity(
  ComicMedia comic,
  LibraryEntityRef entity,
) {
  final releaseId = switch (entity) {
    LibraryWorkRef() => null,
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
  };
  if (releaseId == null) return null;
  for (final release in comic.releases) {
    if (release.id == releaseId) return release;
  }
  throw StateError(
    'Comic release "$releaseId" is not present in the canonical work graph',
  );
}

ComicWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final ComicWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected ComicWorkspaceCatalogData for comic workspace');
}

WorkspaceCommonProjection _comicCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  ComicMedia metadata,
  ComicRelease? release,
) {
  final isWork = node is LibraryWorkRef;
  final title = isWork ? metadata.title : release!.title;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: title,
    overrideSynopsis: isWork ? metadata.synopsis : null,
    overrideReleaseDate:
        release?.releaseDate ?? (isWork ? metadata.releaseDate : null),
    overrideCoverImageUrl:
        release?.coverImageUrl ?? (isWork ? metadata.coverImageUrl : null),
  );
}
