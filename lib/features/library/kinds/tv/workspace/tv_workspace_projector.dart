import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<TvWorkspaceDto> {
  const TvWorkspaceProjector();

  @override
  TvWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    return TvWorkspaceDto(
      common: _tvCommonProjection(item, catalog.metadata),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      metadata: catalog.metadata,
    );
  }
}

TvWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final TvWorkspaceData catalog) return catalog;
  throw StateError('Expected TvWorkspaceData for TV workspace');
}

WorkspaceCommonProjection _tvCommonProjection(
  WorkspaceItem item,
  TvMetadata metadata,
) {
  return WorkspaceCommonProjection.fromKindPresentation(
    item,
    title: metadata.title,
    synopsis: metadata.synopsis,
    releaseDate: metadata.releaseDate ?? metadata.firstAirDate,
    coverImageUrl: metadata.coverImageUrl,
  );
}
