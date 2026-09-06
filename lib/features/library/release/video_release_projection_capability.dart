import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/release/video_release_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

final class VideoReleaseProjectionCapability<TDto extends LibraryWorkspaceDto>
    implements ReleaseProjectionCapability<TDto> {
  const VideoReleaseProjectionCapability();

  @override
  List<LibraryProjectionItem<TDto>> projectReleases({
    required ShelfEntry source,
    required LibraryKindRuntime type,
    required LibraryWorkspaceProjector<TDto> projector,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Map<String, List<String>> customFieldValuesByItem,
    String? requestedTitleId,
  }) {
    final catalogItem = source.catalogItem;
    if (catalogItem == null) return const [];
    final requestedId = requestedTitleId?.trim();
    if (requestedId != null &&
        requestedId.isNotEmpty &&
        catalogItem.id != requestedId) {
      return const [];
    }

    final resolvedEditions = resolveVideoCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems: source.ownedItem == null ? const [] : [source.ownedItem!],
      wishlistItems:
          source.wishlistItem == null ? const [] : [source.wishlistItem!],
    );
    if (resolvedEditions.isEmpty) {
      return const [];
    }

    final items = <LibraryProjectionItem<TDto>>[];
    for (final edition in resolvedEditions) {
      final ownedMatches = source.ownedItem == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: source.ownedItem!.anchor?.editionId,
              variantId: source.ownedItem!.anchor?.variantId,
              bundleReleaseId: source.ownedItem!.anchor?.bundleReleaseId,
            );
      final wishlistMatches = source.wishlistItem == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: source.wishlistItem!.anchor?.editionId,
              variantId: source.wishlistItem!.anchor?.variantId,
              bundleReleaseId: source.wishlistItem!.anchor?.bundleReleaseId,
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
