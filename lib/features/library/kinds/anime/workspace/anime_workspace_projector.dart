import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<AnimeWorkspaceDto> {
  const AnimeWorkspaceProjector();

  @override
  AnimeWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(
        item,
        catalog.metadata,
      ),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      metadata: catalog.metadata,
    );
  }
}

AnimeWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final AnimeWorkspaceData catalog) return catalog;
  throw StateError('Expected AnimeWorkspaceData for anime workspace');
}

WorkspaceCommonProjection _animeCommonProjection(
  WorkspaceItem item,
  AnimeMetadata metadata,
) {
  return WorkspaceCommonProjection.fromKindPresentation(
    item,
    title: metadata.title,
    synopsis: metadata.synopsis,
    releaseDate: metadata.startDate ?? metadata.releaseDate,
    coverImageUrl: metadata.coverImageUrl,
  );
}
