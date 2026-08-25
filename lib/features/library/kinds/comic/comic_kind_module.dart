import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

final comicKindModule = LibraryKindSpec<ComicWorkspaceDto, ComicOwnedDetails>(
  type: comicsLibraryConfig,
  mediaAdapter: comicsMediaAdapter,
  projector: const ComicWorkspaceProjector(),
  ownedDetailsCodec: const ComicOwnedDetailsCodec(),
  fields: comicLibraryKindSchema.toRegistry(),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.comic,
    singularLabel: 'Comic',
    pluralLabel: 'Comics',
    title: 'Comics',
    icon: Icons.collections_bookmark_outlined,
    accent: Color(0xFF44BFE7),
    preferencePrefix: 'comics',
  ),
  metadata: LibraryMetadataCapability(
    defaultProviderId: 'gcd',
    providers: [
      gcdMetadataProvider,
      comicVineMetadataProvider,
      mangadexMetadataProvider,
      anilistMetadataProvider,
      hardcoverMetadataProvider,
    ],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.volumes,
    fetchChildrenCallback: _fetchComicVolumes,
    childrenTitleBuilder: _comicChildrenTitle,
    supportsSeriesSubgroups: true,
    supportsMediaReleaseSplit: false,
    supportsIndexReassignment: true,
    showsReadingQueue: true,
    collectionExportTitleLabel: 'Series',
    mediaReleaseScopeLabel: 'Series',
  ),
  inspector: const LibraryInspectorCapability(
    heroBuilder: buildComicInspectorHero,
    sectionsBuilder: buildComicInspectorSections,
    showsDefaultPersonalSection: false,
  ),
  transfer: const LibraryTransferCapability(
    transferableFieldKeys: comicTransferableFieldKeys,
  ),
  add: const StandardLibraryAddCapability<ComicAddDraft>(
    kind: CatalogMediaKind.comic,
    initialDraftBuilder: ComicAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    comicsLibraryConfig,
    createDraft: createComicEditDraft,
  ),
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
            enabled: context.projection != null &&
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
  buildCardPresentation: buildComicCardPresentation,
);

String _comicChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> _fetchComicVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final volumes = await api
      .getItemVolumes(itemId, kind: CatalogMediaKind.comic.apiValue)
      .timeout(const Duration(seconds: 60));
  return [
    for (final volume in volumes)
      LibraryHierarchyNode(
        id: 'volume_${volume.seasonNumber}',
        label: volume.title,
        secondaryLabel:
            volume.episodeCount != null ? '${volume.episodeCount} items' : null,
        level: LibraryHierarchyLevel.container,
        imageUrl: volume.posterUrl,
        totalCount: volume.episodeCount,
        metadata: {
          'number': volume.seasonNumber,
          'airDate': volume.airDate,
        },
      ),
  ];
}

Iterable<String> _getFacetValues(
    LibraryProjectionRuntime item, String facetId) {
  final source = item.source.catalogItem;
  final metadata = source?.kindMetadata;
  final catalogItem = metadata is ComicCatalogMetadata
      ? ComicCatalogMapper.mapMetadataToComic(metadata, id: source!.identity.id)
      : null;
  if (facetId == ComicFacetIds.character.value) {
    return catalogItem?.characters ?? const [];
  }
  if (facetId == ComicFacetIds.storyArc.value) {
    return catalogItem?.storyArcs ?? const [];
  }
  if (facetId == ComicFacetIds.genre.value) {
    return catalogItem?.genres ?? const [];
  }
  if (facetId == ComicFacetIds.publisher.value) {
    final pub = catalogItem?.publisher;
    return pub != null ? [pub] : const [];
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
