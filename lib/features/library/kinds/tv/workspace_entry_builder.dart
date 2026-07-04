import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_workspace_builder.dart'
    as generic_workspace;
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildTvLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  return generic_workspace.buildGenericLibraryWorkspaceEntryFromShelf(source);
}

LibraryWorkspaceEntry buildTvLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  return generic_workspace.buildGenericLibraryReleaseEntry(request);
}

TvWorkspaceNode buildTvSeriesWorkspaceNode({
  required String id,
  required String title,
}) {
  return TvWorkspaceNode(id: id, title: title, nodeType: TvWorkspaceNodeType.series);
}
