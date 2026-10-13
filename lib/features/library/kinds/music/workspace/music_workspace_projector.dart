import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicCatalogItemWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<MusicWorkspaceProjection> {
  const MusicCatalogItemWorkspaceProjector();

  @override
  MusicCatalogItemWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    return MusicCatalogItemWorkspaceDto(
      common: _musicCommonProjection(item, catalog),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      music: catalog.music,
      facts: catalog.facts,
      listeningSummary: catalog.listeningSummary,
    );
  }
}

final class MusicLibraryEntryWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<MusicWorkspaceProjection> {
  const MusicLibraryEntryWorkspaceProjector();

  @override
  MusicLibraryEntryWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    return MusicLibraryEntryWorkspaceDto(
      common: _musicCommonProjection(item, catalog),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      music: catalog.music,
      facts: catalog.facts,
      listeningSummary: catalog.listeningSummary,
    );
  }
}

MusicWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final MusicWorkspaceData catalog) return catalog;
  throw StateError('Expected MusicWorkspaceData for music workspace');
}

WorkspaceCommonProjection _musicCommonProjection(
  WorkspaceItem item,
  MusicWorkspaceData catalog,
) =>
    WorkspaceCommonProjection.fromKindPresentation(
      item,
      title: catalog.music.title,
      releaseDate: catalog.music.releaseDate,
      coverImageUrl: catalog.music.coverImageUrl,
    );
