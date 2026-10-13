import 'package:collectarr_app/features/library/kinds/manga/data/manga_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<MangaWorkspaceDto> {
  const MangaWorkspaceProjector();

  @override
  MangaWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    final metadata = catalog.metadata;
    final entry =
        MangaLibraryEntryProjection.fromDispatch(item.libraryEntryDispatch);
    final entryDetails =
        entry is MangaLibraryEntry ? entry.personal.details : null;

    return MangaWorkspaceDto(
      common: _mangaCommonProjection(item, metadata),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      metadata: metadata,
      entryDetails: entryDetails,
    );
  }
}

MangaWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final MangaWorkspaceData catalog) return catalog;
  throw StateError('Expected MangaWorkspaceData for manga workspace');
}

WorkspaceCommonProjection _mangaCommonProjection(
  WorkspaceItem item,
  MangaMetadata? metadata,
) {
  return WorkspaceCommonProjection.fromKindPresentation(
    item,
    title: metadata?.title ?? item.title,
    synopsis: metadata?.synopsis ?? metadata?.description,
    releaseDate:
        metadata?.localizedReleaseDate ?? metadata?.originalPublicationDate,
    coverImageUrl: metadata?.coverImageUrl,
  );
}
