import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

abstract interface class LibraryProjectionView<
    TDto extends LibraryWorkspaceDto> {
  LibraryWorkspaceSource get source;
  LibraryNodeRef get node;
  List<String> get customFieldBadges;
  TDto get dto;
}

final class LibraryProjectionItem<TDto extends LibraryWorkspaceDto>
    implements LibraryProjectionView<TDto> {
  const LibraryProjectionItem({
    required this.source,
    required this.node,
    required this.dto,
    this.customFieldBadges = const <String>[],
  });

  static LibraryProjectionItem<LibraryWorkspaceDto> fromShelf(
    LibraryWorkspaceSource source,
    LibraryKindModule type, {
    List<String> customFieldBadges = const <String>[],
  }) {
    final node = LibraryTitleNodeRef(
      titleItemId: source.catalogRef?.id ?? source.itemId,
    );
    final dto = libraryKindWorkspaceForKind(type.kind).projector.projectTitle(
          source: source,
          node: node,
        );
    return LibraryProjectionItem<LibraryWorkspaceDto>(
      source: source,
      node: node,
      dto: dto,
      customFieldBadges: customFieldBadges,
    );
  }

  @override
  final LibraryWorkspaceSource source;
  @override
  final LibraryNodeRef node;
  @override
  final TDto dto;
  @override
  final List<String> customFieldBadges;
}

Set<String> customFieldTargetIds({
  required LibraryWorkspaceSource source,
  required LibraryNodeRef node,
}) {
  return {
    if (source.ownedSummary case final owned?) owned.ref.id.value,
    if (source.ownedRef case final owned?) owned.id.value,
    if (source.catalogRef case final catalog?) catalog.id,
    node.titleItemId,
    if (node case LibraryReleaseNodeRef(:final releaseId)) releaseId,
    if (node
        case LibraryCopyNodeRef(
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
  LibraryKindModule type, {
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
      const {},
  Map<String, List<String>> customFieldValuesByItem = const {},
  LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
  String? releaseFolderTitleItemId,
}) {
  final kind = type.kind;
  final workspace = libraryKindWorkspaceForKind(kind);
  if (browserMode == LibraryWorkspaceBrowserMode.releases) {
    final releaseCap = type.releaseCapability;
    if (releaseCap == null) {
      throw UnsupportedError(
        'Release projection capability is not supported for ${kind.apiValue}',
      );
    }
    return [
      for (final source in shelf.resolvedWorkspaceEntries)
        if (source.catalogRef?.mediaKind == kind)
          ...releaseCap.projectReleases(
            source: source,
            type: type,
            projector: workspace.projector,
            customFieldDefinitions: customFieldDefinitions,
            customFieldValuesByDefinitionByItem:
                customFieldValuesByDefinitionByItem,
            customFieldValuesByItem: customFieldValuesByItem,
            requestedTitleId: releaseFolderTitleItemId,
          ),
    ];
  }
  return [
    for (final source in shelf.resolvedWorkspaceEntries)
      if (source.catalogRef?.mediaKind == kind)
        type.titleCapability.projectTitle(
          source: source,
          node: LibraryTitleNodeRef(
            titleItemId: source.catalogRef?.id ?? source.itemId,
          ),
          projector: workspace.projector,
          customFieldBadges: customFieldBadgesForNode(
            source: source,
            node: LibraryTitleNodeRef(
              titleItemId: source.catalogRef?.id ?? source.itemId,
            ),
            customFieldDefinitions: customFieldDefinitions,
            customFieldValuesByDefinitionByItem:
                customFieldValuesByDefinitionByItem,
            customFieldValuesByItem: customFieldValuesByItem,
          ),
        ),
  ];
}

List<String> customFieldBadgesForNode({
  required LibraryWorkspaceSource source,
  required LibraryNodeRef node,
  required List<CustomFieldDefinition> customFieldDefinitions,
  required Map<String, Map<String, String>> customFieldValuesByDefinitionByItem,
  required Map<String, List<String>> customFieldValuesByItem,
}) {
  final candidateIds = customFieldTargetIds(source: source, node: node);
  return _customFieldBadgesFromIds(
    candidateIds,
    customFieldDefinitions: customFieldDefinitions,
    customFieldValuesByDefinitionByItem: customFieldValuesByDefinitionByItem,
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
