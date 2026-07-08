import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart'
    as comic_add;
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:flutter/material.dart';

final comicKindModule = LibraryKindModule(
  type: comicsLibraryConfig,
  mediaAdapter: comicsMediaAdapter,
  workspaceDtoFactory: ComicWorkspaceDto.fromEntry,
  add: LibraryKindAddModule(registerBuilders: comic_add.registerComicAddBuilders),
  workspaceBehavior: LibraryKindWorkspaceBehavior(
    supportsSeriesIssueJump: true,
    issueSortNumber: comicIssueSortNumber,
  ),
  toolbar: LibraryKindToolbarModule(
    actions: [
      LibraryToolbarActionDescriptor(
        id: 'comic.missing_issues',
        label: 'Missing issues report...',
        icon: Icons.find_in_page_outlined,
        section: 'Collection',
        buildAction: (context) {
          final projection = context.projection;
          return LibraryUtilityMenuAction(
            icon: Icons.find_in_page_outlined,
            label: 'Missing issues report...',
            section: 'Collection',
            enabled: projection != null,
            onSelected: projection == null
                ? null
                : () => context.onMissingSequenceReport?.call(projection),
          );
        },
      ),
    ],
  ),
  providerMapper: const ComicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(loadRows: _loadComicFacetRows),
);

Future<List<Map<String, dynamic>>> _loadComicFacetRows(
  LibraryFacetRequest request,
) async {
  return request.groupMode == LibraryGroupMode.storyArc
      ? request.api.storyArcFacets(request.itemIds)
      : request.api.characterFacets(request.itemIds);
}
