import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart'
    show buildReleaseEntryData, buildShelfWorkspaceEntryData;
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildMusicLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem!;
  return MusicWorkspaceEntry(
    common: buildShelfWorkspaceEntryData(source, mediaType: 'music'),
    series: item.series,
    publishing: item.publishing,
    music: item.music,
  );
}

LibraryWorkspaceEntry buildMusicLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return MusicWorkspaceEntry(
    common: buildReleaseEntryData(request, mediaType: 'music'),
    series: entry.series,
    publishing: entry.publishing,
    music: entry.music,
  );
}