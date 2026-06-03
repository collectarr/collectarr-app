import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart'
  show buildReleaseEntryData, buildShelfWorkspaceEntryData;
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildMoviesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem!;
  final common = buildShelfWorkspaceEntryData(source);
  return switch (common.mediaType) {
    'tv' => TvWorkspaceEntry(
        common: common,
        series: item.series,
        publishing: item.publishing,
        video: item.video,
      ),
    'anime' => AnimeWorkspaceEntry(
        common: common,
        series: item.series,
        publishing: item.publishing,
        video: item.video,
      ),
    _ => MovieWorkspaceEntry(
        common: common,
        series: item.series,
        publishing: item.publishing,
        video: item.video,
      ),
  };
}

LibraryWorkspaceEntry buildMoviesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  final common = buildReleaseEntryData(request);
  return switch (common.mediaType) {
    'tv' => TvWorkspaceEntry(
        common: common,
        series: entry.series,
        publishing: entry.publishing,
        video: entry.video,
      ),
    'anime' => AnimeWorkspaceEntry(
        common: common,
        series: entry.series,
        publishing: entry.publishing,
        video: entry.video,
      ),
    _ => MovieWorkspaceEntry(
        common: common,
        series: entry.series,
        publishing: entry.publishing,
        video: entry.video,
      ),
  };
}