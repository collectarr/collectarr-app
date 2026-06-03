import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart'
    show buildReleaseEntryData, buildShelfWorkspaceEntryData;
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildBooksLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem!;
  return BookWorkspaceEntry(
    common: buildShelfWorkspaceEntryData(source, mediaType: 'book'),
    series: item.series,
    publishing: item.publishing,
  );
}

LibraryWorkspaceEntry buildBooksLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return BookWorkspaceEntry(
    common: buildReleaseEntryData(request, mediaType: 'book'),
    series: entry.series,
    publishing: entry.publishing,
  );
}