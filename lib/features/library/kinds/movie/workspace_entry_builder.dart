import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart'
    show buildReleaseEntryData, buildShelfWorkspaceEntryData, buildVideoWorkspaceEntry;
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildMoviesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem!;
  return buildVideoWorkspaceEntry(
    common: buildShelfWorkspaceEntryData(source),
    series: item.series,
    publishing: item.publishing,
    video: item.video,
  );
}

LibraryWorkspaceEntry buildMoviesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return buildVideoWorkspaceEntry(
    common: buildReleaseEntryData(request),
    series: entry.series,
    publishing: entry.publishing,
    video: entry.video,
  );
}