import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MangaWorkspaceDto> {
  const MangaWorkspaceProjector();

  @override
  MangaWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    final catalog = _catalogFor(source);
    final metadata = catalog.metadata;
    final owned =
        MangaOwnedItemProjection.fromDispatch(source.ownedItemDispatch);
    final ownedDetails = owned is MangaOwnedItem ? owned.details : null;

    return MangaWorkspaceDto(
      common: _mangaCommonProjection(source, entity, metadata),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      metadata: metadata,
      ownedDetails: ownedDetails,
    );
  }
}

MangaWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final MangaWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected MangaWorkspaceCatalogData for manga workspace');
}

WorkspaceCommonProjection _mangaCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
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
