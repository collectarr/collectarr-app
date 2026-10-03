import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

abstract interface class LibraryProjectionView<
    TDto extends LibraryWorkspaceDto> {
  LibraryWorkspaceSource get source;
  LibraryEntityRef get node;
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
    LibraryKindRegistration type, {
    List<String> customFieldBadges = const <String>[],
  }) {
    final node = LibraryCatalogItemNodeRef(
      catalogItemId: source.catalogRef?.id ?? source.itemId,
      libraryEntryRef: source.libraryEntryRef,
    );
    final dto = libraryKindWorkspaceForKind(type.kind)
        .projectorForScope(LibraryEntityScope.catalogItem)
        .project(
          source: source,
          entity: node,
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
  final LibraryEntityRef node;
  @override
  final TDto dto;
  @override
  final List<String> customFieldBadges;
}

Set<String> customFieldTargetIds({
  required LibraryWorkspaceSource source,
  required LibraryEntityRef node,
}) {
  return {
    if (source.libraryEntrySummary case final entry?) ...[
      entry.ref.key,
      entry.ref.id.value,
    ],
    if (source.libraryEntryRef case final entry?) ...[
      entry.key,
      entry.id.value,
    ],
    if (source.catalogRef case final catalog?) catalog.id,
    node.catalogItemId,
    if (node case LibraryEntryNodeRef(:final libraryEntryRef)) ...[
      libraryEntryRef.key,
      libraryEntryRef.id.value,
    ],
  };
}

List<LibraryProjectionItem<LibraryWorkspaceDto>> libraryItemsForShelf(
  ShelfState shelf,
  LibraryKindRegistration type, {
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
      const {},
  Map<String, List<String>> customFieldValuesByItem = const {},
}) {
  final kind = type.kind;
  return [
    for (final source in shelf.entries)
      if (source.catalogRef?.mediaKind == kind &&
          source.catalogData?.kind == kind)
        LibraryProjectionItem.fromShelf(
          source,
          type,
          customFieldBadges: customFieldBadgesForNode(
            source: source,
            node: LibraryCatalogItemNodeRef(
              catalogItemId: source.catalogRef?.id ?? source.itemId,
              libraryEntryRef: source.libraryEntryRef,
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
  required LibraryEntityRef node,
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
