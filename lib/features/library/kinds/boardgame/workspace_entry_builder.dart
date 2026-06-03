import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart'
    show buildReleaseEntryData, buildShelfWorkspaceEntryData;
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildBoardGamesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem!;
  return BoardGameWorkspaceEntry(
    common: buildShelfWorkspaceEntryData(source, mediaType: 'boardgame'),
    series: item.series,
    publishing: item.publishing,
    game: item.game,
  );
}

LibraryWorkspaceEntry buildBoardGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return BoardGameWorkspaceEntry(
    common: buildReleaseEntryData(request, mediaType: 'boardgame'),
    series: entry.series,
    publishing: entry.publishing,
    game: entry.game,
  );
}