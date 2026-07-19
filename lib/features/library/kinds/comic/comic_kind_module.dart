import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart'
    as comic_add;
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

final comicKindModule = LibraryKindModule(
  type: comicsLibraryConfig,
  mediaAdapter: comicsMediaAdapter,
  workspaceDtoFactory: ComicWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: comicLibraryGroupDefinitions,
    sorts: comicLibrarySortDefinitions,
    columns: comicLibraryColumnDefinitions,
    defaultVisibleColumnIds: comicLibraryDefaultVisibleColumnIds,
    defaultSortId: comicDefaultSortId,
    defaultGroupId: comicDefaultGroupId,
    customLinkedMetadataCandidates: (entry) sync* {
      yield* AnyLibraryFieldRegistry.nonEmptyStrings(entry.characters);
      yield* AnyLibraryFieldRegistry.nonEmptyStrings(entry.storyArcs);
    },
  ),
  add: LibraryKindAddModule(registerBuilders: comic_add.registerComicAddBuilders),
  workspaceBehavior: LibraryKindWorkspaceBehavior(
    supportsSeriesIssueJump: true,
    issueSortNumber: comicIssueSortNumber,
  ),
  toolbar: LibraryKindToolbarModule(
    actions: [
      LibraryToolbarActionDescriptor(
        id: 'comic.jump_to_issue',
        label: 'Jump to issue...',
        icon: Icons.tag_outlined,
        section: 'Collection',
        buildAction: (buildContext, context) {
          return LibraryUtilityMenuAction(
            icon: Icons.tag_outlined,
            label: 'Jump to issue...',
            section: 'Collection',
            enabled:
                context.projection != null &&
                context.onJumpToNumberSubmitted != null,
            onSelected: context.projection == null ||
                    context.onJumpToNumberSubmitted == null
                ? null
                : () => _showJumpToIssueDialog(
                      buildContext,
                      onSubmitted: context.onJumpToNumberSubmitted!,
                    ),
          );
        },
      ),
      LibraryToolbarActionDescriptor(
        id: 'comic.missing_issues',
        label: 'Missing issues report...',
        icon: Icons.find_in_page_outlined,
        section: 'Collection',
        buildAction: (buildContext, context) {
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
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getFacetValues,
  ),
);

Iterable<String> _getFacetValues(LibraryWorkspaceEntry entry, String facetId) {
  if (facetId == 'comic.character' || facetId == 'media.character') {
    return entry.characters ?? const [];
  }
  if (facetId == 'comic.story_arc') {
    return entry.storyArcs ?? const [];
  }
  return const [];
}

Future<void> _showJumpToIssueDialog(
  BuildContext context, {
  required void Function(String value) onSubmitted,
}) async {
  final controller = TextEditingController();
  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        void submit() {
          final value = controller.text.trim();
          if (value.isEmpty) {
            return;
          }
          Navigator.of(dialogContext).pop();
          onSubmitted(value);
        }

        return AlertDialog(
          title: const Text('Jump to issue'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Issue #',
            ),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submit,
              child: const Text('Jump'),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
