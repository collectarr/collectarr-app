import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceProjector
    implements LibraryWorkspaceProjector<ComicWorkspaceDto> {
  const ComicWorkspaceProjector();

  @override
  ComicWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = source.catalogItem;
    final rawMetadata = catalog?.kindMetadata;
    final ComicMedia metadata;
    if (rawMetadata is ComicMedia) {
      metadata = rawMetadata;
    } else if (rawMetadata != null) {
      metadata = ComicMedia.fromJson(catalog!.payload);
    } else {
      throw StateError('Expected ComicMedia for comic workspace');
    }
    final ownedItem =
        ComicOwnedItemProjection.tryFromOwnedItem(source.ownedItem);
    return ComicWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      comic: metadata,
      ownedItem: ownedItem,
    );
  }

  @override
  ComicWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    throw UnsupportedError(
        'Release projection is not supported for ComicWorkspaceProjector');
  }

  @override
  ComicWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    throw UnsupportedError(
        'Copy projection is not supported for ComicWorkspaceProjector');
  }
}
