import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceProjector
    implements LibraryWorkspaceProjector<MangaWorkspaceDto> {
  const MangaWorkspaceProjector();

  @override
  MangaWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    MangaMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is MangaMetadata) {
      metadata = km;
    }
    MangaOwnedDetails? ownedDetails;
    final det = source.ownedItem?.details;
    if (det is MangaOwnedDetails) {
      ownedDetails = det;
    }

    return MangaWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      metadata: metadata,
      ownedDetails: ownedDetails,
    );
  }

  @override
  MangaWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    throw UnsupportedError(
        'Release projection is not supported for MangaWorkspaceProjector');
  }

  @override
  MangaWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    throw UnsupportedError(
        'Copy projection is not supported for MangaWorkspaceProjector');
  }
}
