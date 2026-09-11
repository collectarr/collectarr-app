import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/release/video_release_source.dart'
    hide preferredVideoEditionVariantId;
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';

final class VideoReleaseProjectionCapability<TDto extends LibraryWorkspaceDto>
    implements ReleaseProjectionCapability<TDto> {
  const VideoReleaseProjectionCapability();

  @override
  List<LibraryProjectionItem<TDto>> projectReleases({
    required LibraryWorkspaceSource source,
    required LibraryKindModule type,
    required LibraryWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedTitleId,
  }) {
    final catalogItem = source.catalogTransport;
    if (catalogItem == null) return const [];
    final requestedId = requestedTitleId?.trim();
    if (requestedId != null &&
        requestedId.isNotEmpty &&
        catalogItem.id != requestedId) {
      return const [];
    }

    final resolvedEditions = resolveVideoCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems:
          source.ownedSummary == null ? const [] : [source.ownedSummary!],
      wishlistItems:
          source.wishlistItem == null ? const [] : [source.wishlistItem!],
    );
    if (resolvedEditions.isEmpty) {
      return const [];
    }

    final items = <LibraryProjectionItem<TDto>>[];
    for (final edition in resolvedEditions) {
      final ownedMatches = source.ownedSummary == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: catalogRefEditionId(source.ownedSummary!.targetRef),
              variantId: catalogRefVariantId(source.ownedSummary!.targetRef),
              bundleReleaseId:
                  catalogRefBundleReleaseId(source.ownedSummary!.targetRef),
            );
      final wishlistMatches = source.wishlistItem == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: catalogRefEditionId(source.wishlistItem!.catalogRef),
              variantId: catalogRefVariantId(source.wishlistItem!.catalogRef),
              bundleReleaseId:
                  catalogRefBundleReleaseId(source.wishlistItem!.catalogRef),
            );

      final releaseNode = LibraryReleaseNodeRef(
        titleItemId: catalogItem.id,
        releaseId: edition.id,
        edition: edition,
      );
      final releaseState = LibraryReleaseState(
        isOwned: ownedMatches,
        isWishlisted: wishlistMatches,
        isTracked: source.isTracked,
        referenceEditionId: edition.id,
        referenceVariantId: preferredVideoEditionVariantId(edition),
      );

      final dto = projector.projectRelease(
        source: source,
        node: releaseNode,
        releaseState: releaseState,
      );

      items.add(
        LibraryProjectionItem<TDto>(
          source: source,
          node: releaseNode,
          dto: dto,
          customFieldBadges: customFieldBadgesForNode(
            source: source,
            node: releaseNode,
            customFieldDefinitions: customFieldDefinitions,
            customFieldValuesByDefinitionByItem:
                customFieldValuesByDefinitionByItem,
            customFieldValuesByItem: customFieldValuesByItem,
          ),
        ),
      );
    }
    return items;
  }
}
