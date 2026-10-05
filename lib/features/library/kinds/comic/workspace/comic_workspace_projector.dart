import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<ComicWorkspaceDto> {
  const ComicWorkspaceProjector();

  @override
  ComicWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    final libraryEntry =
        ComicLibraryEntryProjection.fromDispatch(item.libraryEntryDispatch);
    return ComicWorkspaceDto(
      common: _comicCommonProjection(item, catalog.comic),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      comic: catalog.comic,
      libraryEntry: libraryEntry,
    );
  }
}

ComicWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final ComicWorkspaceData catalog) return catalog;
  throw StateError('Expected ComicWorkspaceData for comic workspace');
}

WorkspaceCommonProjection _comicCommonProjection(
  WorkspaceItem item,
  ComicCatalogItem metadata,
) {
  return WorkspaceCommonProjection.fromKindPresentation(
    item,
    title: metadata.title,
    synopsis: metadata.synopsis,
    releaseDate: metadata.releaseDate,
    coverImageUrl: metadata.coverImageUrl,
  );
}
