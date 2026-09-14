import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceProjector
    implements LibraryWorkspaceProjector<MangaWorkspaceDto> {
  const MangaWorkspaceProjector();

  @override
  MangaWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    final metadata = catalog.metadata;
    final owned =
        MangaOwnedItemProjection.fromDispatch(source.ownedItemDispatch);
    final ownedDetails = owned is MangaOwnedItem ? owned.details : null;

    return MangaWorkspaceDto(
      common: _mangaCommonProjection(source, node, metadata),
      personal: PersonalCopyProjection.fromShelf(source),
      metadata: metadata,
      ownedDetails: ownedDetails,
    );
  }

  @override
  MangaWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    throw UnsupportedError(
        'Release projection is not supported for MangaWorkspaceProjector');
  }

  @override
  MangaWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    throw UnsupportedError(
        'Copy projection is not supported for MangaWorkspaceProjector');
  }
}

MangaWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final MangaWorkspaceCatalogData catalog) return catalog;
  final snapshot = source.catalogSnapshot;
  if (snapshot != null) {
    return snapshot.mapTransport(MangaWorkspaceCatalogData.fromTransport);
  }
  throw StateError('Expected MangaWorkspaceCatalogData for manga workspace');
}

WorkspaceCommonProjection _mangaCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
  MangaMetadata? metadata,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: metadata?.title,
    overrideReleaseDate:
        metadata?.localizedReleaseDate ?? metadata?.originalPublicationDate,
  );
}
