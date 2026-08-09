import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
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
  LibraryTypeConfig type, {
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
      const {},
  Map<String, List<String>> customFieldValuesByItem = const {},
  LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
  String? releaseFolderTitleItemId,
}) {
  final kind = type.workspace.kind;
  if (browserMode == LibraryWorkspaceBrowserMode.releases) {
    final releaseCap = type.releaseCapability;
    if (releaseCap == null) {
      throw UnsupportedError(
        'Release projection capability is not supported for ${kind.apiValue}',
      );
    }
    return [
      for (final source in shelf.entries)
        if (source.catalogItem != null &&
            source.catalogItem!.kind == kind.apiValue)
          ...releaseCap.projectReleases(
            source: source,
            type: type,
            projector: type.presentation.projector,
            customFieldDefinitions: customFieldDefinitions,
            customFieldValuesByDefinitionByItem:
                customFieldValuesByDefinitionByItem,
            customFieldValuesByItem: customFieldValuesByItem,
            requestedTitleId: releaseFolderTitleItemId,
          ),
    ];
  }
  return [
    for (final source in shelf.entries)
      if (source.catalogItem != null &&
          source.catalogItem!.kind == kind.apiValue)
        type.titleCapability.projectTitle(
          source: source,
          node: LibraryTitleNodeRef(titleItemId: source.catalogItem!.id),
          projector: type.presentation.projector,
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
