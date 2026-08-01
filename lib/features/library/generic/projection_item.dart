import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/media/video/video_release_source.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

abstract interface class LibraryProjectionRuntime {
  ShelfEntry get source;
  LibraryNodeRef get node;
  List<String> get customFieldBadges;
  LibraryWorkspaceDto get dto;
}

final class LibraryProjectionItem<TDto extends LibraryWorkspaceDto>
    implements LibraryProjectionRuntime {
  const LibraryProjectionItem({
    required this.source,
    required this.node,
    required this.dto,
    this.customFieldBadges = const <String>[],
  });

  factory LibraryProjectionItem.fromShelf(
    ShelfEntry source,
    LibraryTypeConfig type, {
    List<String> customFieldBadges = const <String>[],
  }) {
    final item = source.catalogItem!;
    final node = LibraryTitleNodeRef(titleItemId: item.id);
    final dto = type.presentation.projector.projectTitle(
      source: source,
      node: node,
    ) as TDto;
    return LibraryProjectionItem<TDto>(
      source: source,
      node: node,
      dto: dto,
      customFieldBadges: customFieldBadges,
    );
  }

  @override
  final ShelfEntry source;
  @override
  final LibraryNodeRef node;
  @override
  final TDto dto;
  @override
  final List<String> customFieldBadges;
}

Set<String> customFieldTargetIds({
  required ShelfEntry source,
  required LibraryNodeRef node,
}) {
  return {
    if (source.ownedItem case final owned?) owned.id,
    if (source.catalogItem case final catalog?) catalog.id,
    node.titleItemId,
    if (node case LibraryReleaseNodeRef(:final releaseId)) releaseId,
    if (node case LibraryCopyNodeRef(
      :final ownedItemId,
      :final copyId,
    )) ...[
      ownedItemId,
      if (copyId != null) copyId,
    ],
  };
}

List<LibraryProjectionItem<LibraryWorkspaceDto>> libraryItemsForShelf(
  ShelfState shelf,
  LibraryTypeConfig type, {
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem = const {},
  Map<String, List<String>> customFieldValuesByItem = const {},
  LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
  String? releaseFolderTitleItemId,
}) {
  final kind = type.workspace.kind;
  if (browserMode == LibraryWorkspaceBrowserMode.releases) {
    return _libraryReleaseItemsForShelf(
      shelf,
      type,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByDefinitionByItem:
          customFieldValuesByDefinitionByItem,
      customFieldValuesByItem: customFieldValuesByItem,
      releaseFolderTitleItemId: releaseFolderTitleItemId,
    );
  }
  return [
    for (final source in shelf.entries)
      if (source.catalogItem != null && source.catalogItem!.kind == kind.apiValue)
        LibraryProjectionItem.fromShelf(
          source,
          type,
          customFieldBadges: customFieldBadgesForNode(
            source: source,
            node: LibraryTitleNodeRef(titleItemId: source.catalogItem!.id),
            customFieldDefinitions: customFieldDefinitions,
            customFieldValuesByDefinitionByItem:
                customFieldValuesByDefinitionByItem,
            customFieldValuesByItem: customFieldValuesByItem,
          ),
        ),
  ];
}

List<LibraryProjectionItem<LibraryWorkspaceDto>> _libraryReleaseItemsForShelf(
  ShelfState shelf,
  LibraryTypeConfig type, {
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem = const {},
  Map<String, List<String>> customFieldValuesByItem = const {},
  String? releaseFolderTitleItemId,
}) {
  final kind = type.workspace.kind;
  final requestedTitleId = releaseFolderTitleItemId?.trim();
  final items = <LibraryProjectionItem<LibraryWorkspaceDto>>[];

  for (final source in shelf.entries) {
    final catalogItem = source.catalogItem;
    if (catalogItem == null || catalogItem.kind != kind.apiValue) {
      continue;
    }
    if (requestedTitleId != null && catalogItem.id != requestedTitleId) {
      continue;
    }

    final resolvedEditions = resolveVideoCatalogEditionsForCatalogItem(
      catalogItem,
      ownedItems:
          source.ownedItem == null ? const [] : [source.ownedItem!],
      wishlistItems:
          source.wishlistItem == null ? const [] : [source.wishlistItem!],
    );
    if (resolvedEditions.isEmpty) {
      // Hide media that have no release-level data in release mode.
      continue;
    }

    for (final edition in resolvedEditions) {
      final ownedMatches = source.ownedItem == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: source.ownedItem!.editionId,
              variantId: source.ownedItem!.variantId,
              bundleReleaseId: source.ownedItem!.bundleReleaseId,
            );
      final wishlistMatches = source.wishlistItem == null
          ? false
          : matchesVideoReleaseAnchor(
              edition,
              editionId: source.wishlistItem!.editionId,
              variantId: source.wishlistItem!.variantId,
              bundleReleaseId: source.wishlistItem!.bundleReleaseId,
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

      final dto = type.presentation.projector.projectRelease(
        source: source,
        node: releaseNode,
        releaseState: releaseState,
      );

      items.add(
        LibraryProjectionItem<LibraryWorkspaceDto>(
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
  }
  return items;
}

List<String> customFieldBadgesForNode({
  required ShelfEntry source,
  required LibraryNodeRef node,
  required List<CustomFieldDefinition> customFieldDefinitions,
  required Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
  required Map<String, List<String>> customFieldValuesByItem,
}) {
  final candidateIds = customFieldTargetIds(source: source, node: node);
  return _customFieldBadgesFromIds(
    candidateIds,
    customFieldDefinitions: customFieldDefinitions,
    customFieldValuesByDefinitionByItem:
        customFieldValuesByDefinitionByItem,
    customFieldValuesByItem: customFieldValuesByItem,
  );
}

List<String> _customFieldBadgesFromIds(
  Iterable<String> targetIds, {
  required List<CustomFieldDefinition> customFieldDefinitions,
  required Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
  required Map<String, List<String>> customFieldValuesByItem,
}) {
  if (customFieldDefinitions.isEmpty) {
    return const [];
  }
  final seen = <String>{};
  final badges = <String>[];
  for (final targetId in targetIds) {
    final byDefinition = customFieldValuesByDefinitionByItem[targetId];
    if (byDefinition == null || byDefinition.isEmpty) {
      continue;
    }
    for (final definition in customFieldDefinitions) {
      final value = byDefinition[definition.id]?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      final name = definition.name.trim();
      final label = name.isEmpty ? value : '$name: $value';
      if (seen.add(label)) {
        badges.add(label);
      }
      if (badges.length >= 3) {
        return badges;
      }
    }
  }
  if (badges.isNotEmpty) {
    return badges;
  }
  for (final targetId in targetIds) {
    final values = customFieldValuesByItem[targetId];
    if (values == null || values.isEmpty) {
      continue;
    }
    for (final value in values) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        continue;
      }
      if (seen.add(normalized)) {
        badges.add(normalized);
      }
      if (badges.length >= 3) {
        return badges;
      }
    }
  }
  return badges;
}
