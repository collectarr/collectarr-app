import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<MovieWorkspaceDto> {
  const MovieWorkspaceProjector();

  @override
  MovieWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    return MovieWorkspaceDto(
      common: WorkspaceCommonProjection.fromKindPresentation(
        item,
        title: catalog.metadata.title,
        synopsis: catalog.metadata.synopsis,
        releaseDate: catalog.metadata.releaseDate ??
            catalog.metadata.releaseDateParts?.asDateTime,
        coverImageUrl: catalog.metadata.coverImageUrl,
      ),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      metadata: catalog.metadata,
    );
  }
}

MovieWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final MovieWorkspaceData catalog) return catalog;
  throw StateError('Expected MovieWorkspaceData for movie workspace');
}
