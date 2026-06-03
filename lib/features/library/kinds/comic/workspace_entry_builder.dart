import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart'
  show buildReleaseEntryData, buildShelfWorkspaceEntryData;
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildComicsLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem!;
  final ownedItem = source.ownedItem;
  return ComicWorkspaceEntry(
    common: buildShelfWorkspaceEntryData(source, mediaType: 'comic'),
    comic: ComicWorkspaceDetails(
      rawOrSlabbed: ownedItem?.rawOrSlabbed,
      gradingCompany: ownedItem?.gradingCompany,
      labelType: ownedItem?.labelType,
      certificationNumber: ownedItem?.certificationNumber,
      keyComic: ownedItem?.keyComic ?? false,
      keyReason: ownedItem?.keyReason,
    ),
    series: item.series,
    publishing: item.publishing,
  );
}

LibraryWorkspaceEntry buildComicsLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return ComicWorkspaceEntry(
    common: buildReleaseEntryData(request, mediaType: 'comic'),
    comic: entry.comic,
    series: entry.series,
    publishing: entry.publishing,
  );
}